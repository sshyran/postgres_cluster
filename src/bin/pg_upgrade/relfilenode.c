/*
 *	relfilenode.c
 *
 *	relfilenode functions
 *
 *	Copyright (c) 2010-2016, PostgreSQL Global Development Group
 *	src/bin/pg_upgrade/relfilenode.c
 */

#include "postgres_fe.h"

#include "pg_upgrade.h"

#include <sys/stat.h>
#include "catalog/pg_class.h"
#include "access/transam.h"


static void transfer_single_new_db(FileNameMap *maps, int size, char *old_tablespace);
static void transfer_relfile(FileNameMap *map, const char *suffix, bool vm_must_add_frozenbit);


/*
 * transfer_all_new_tablespaces()
 *
 * Responsible for upgrading all database. invokes routines to generate mappings and then
 * physically link the databases.
 */
void
transfer_all_new_tablespaces(DbInfoArr *old_db_arr, DbInfoArr *new_db_arr,
							 char *old_pgdata, char *new_pgdata)
{
	pg_log(PG_REPORT, "%s user relation files\n",
	  user_opts.transfer_mode == TRANSFER_MODE_LINK ? "Linking" : "Copying");

	/*
	 * Transferring files by tablespace is tricky because a single database
	 * can use multiple tablespaces.  For non-parallel mode, we just pass a
	 * NULL tablespace path, which matches all tablespaces.  In parallel mode,
	 * we pass the default tablespace and all user-created tablespaces and let
	 * those operations happen in parallel.
	 */
	if (user_opts.jobs <= 1)
		parallel_transfer_all_new_dbs(old_db_arr, new_db_arr, old_pgdata,
									  new_pgdata, NULL);
	else
	{
		int			tblnum;

		/* transfer default tablespace */
		parallel_transfer_all_new_dbs(old_db_arr, new_db_arr, old_pgdata,
									  new_pgdata, old_pgdata);

		for (tblnum = 0; tblnum < os_info.num_old_tablespaces; tblnum++)
			parallel_transfer_all_new_dbs(old_db_arr,
										  new_db_arr,
										  old_pgdata,
										  new_pgdata,
										  os_info.old_tablespaces[tblnum]);
		/* reap all children */
		while (reap_child(true) == true)
			;
	}

	end_progress_output();
	check_ok();

	return;
}


/*
 * transfer_all_new_dbs()
 *
 * Responsible for upgrading all database. invokes routines to generate mappings and then
 * physically link the databases.
 */
void
transfer_all_new_dbs(DbInfoArr *old_db_arr, DbInfoArr *new_db_arr,
					 char *old_pgdata, char *new_pgdata, char *old_tablespace)
{
	int			old_dbnum,
				new_dbnum;

	/* Scan the old cluster databases and transfer their files */
	for (old_dbnum = new_dbnum = 0;
		 old_dbnum < old_db_arr->ndbs;
		 old_dbnum++, new_dbnum++)
	{
		DbInfo	   *old_db = &old_db_arr->dbs[old_dbnum],
				   *new_db = NULL;
		FileNameMap *mappings;
		int			n_maps;

		/*
		 * Advance past any databases that exist in the new cluster but not in
		 * the old, e.g. "postgres".  (The user might have removed the
		 * 'postgres' database from the old cluster.)
		 */
		for (; new_dbnum < new_db_arr->ndbs; new_dbnum++)
		{
			new_db = &new_db_arr->dbs[new_dbnum];
			if (strcmp(old_db->db_name, new_db->db_name) == 0)
				break;
		}

		if (new_dbnum >= new_db_arr->ndbs)
			pg_fatal("old database \"%s\" not found in the new cluster\n",
					 old_db->db_name);

		mappings = gen_db_file_maps(old_db, new_db, &n_maps, old_pgdata,
									new_pgdata);
		if (n_maps)
		{
			print_maps(mappings, n_maps, new_db->db_name);

			transfer_single_new_db(mappings, n_maps, old_tablespace);
		}
		/* We allocate something even for n_maps == 0 */
		pg_free(mappings);
	}

	return;
}

static void transfer_compression_files(FileNameMap *map)
{
	char		old_file[MAXPGPATH];
	char		new_file[MAXPGPATH];
	struct stat statbuf;		

	snprintf(old_file, sizeof(old_file), "%s%s/pg_compression",
			 map->old_tablespace,
			 map->old_tablespace_suffix);
	snprintf(new_file, sizeof(new_file), "%s%s/pg_compression",
			 map->new_tablespace,
			 map->new_tablespace_suffix);
	
	if (stat(old_file, &statbuf) == 0)
	{
		unlink(new_file);

		if (user_opts.transfer_mode == TRANSFER_MODE_COPY)
		{
			pg_log(PG_VERBOSE, "copying \"%s\" to \"%s\"\n", old_file, new_file);

			copyFile(old_file, new_file, map->nspname, map->relname);

		}
		else
		{
			pg_log(PG_VERBOSE, "linking \"%s\" to \"%s\"\n", old_file, new_file);

			linkFile(old_file, new_file, map->nspname, map->relname);

		}

		transfer_relfile(map, ".cfm", false);
	}
}

/*
 * transfer_single_new_db()
 *
 * create links for mappings stored in "maps" array.
 */
static void
transfer_single_new_db(FileNameMap *maps, int size, char *old_tablespace)
{
	int			mapnum;
	bool		vm_crashsafe_match = true;
	bool		vm_must_add_frozenbit = false;

	/*
	 * Do the old and new cluster disagree on the crash-safetiness of the vm
	 * files?  If so, do not copy them.
	 */
	if (old_cluster.controldata.cat_ver < VISIBILITY_MAP_CRASHSAFE_CAT_VER &&
		new_cluster.controldata.cat_ver >= VISIBILITY_MAP_CRASHSAFE_CAT_VER)
		vm_crashsafe_match = false;

	/*
	 * Do we need to rewrite visibilitymap?
	 */
	if (old_cluster.controldata.cat_ver < VISIBILITY_MAP_FROZEN_BIT_CAT_VER &&
		new_cluster.controldata.cat_ver >= VISIBILITY_MAP_FROZEN_BIT_CAT_VER)
		vm_must_add_frozenbit = true;

	for (mapnum = 0; mapnum < size; mapnum++)
	{
		if (old_tablespace == NULL ||
			strcmp(maps[mapnum].old_tablespace, old_tablespace) == 0)
		{
			transfer_compression_files(&maps[mapnum]);

			/* transfer primary file */
			transfer_relfile(&maps[mapnum], "", vm_must_add_frozenbit);

			/* fsm/vm files added in PG 8.4 */
			if (GET_MAJOR_VERSION(old_cluster.major_version) >= 804)
			{
				/*
				 * Copy/link any fsm and vm files, if they exist
				 */
				transfer_relfile(&maps[mapnum], "_fsm", vm_must_add_frozenbit);
				if (vm_crashsafe_match)
					transfer_relfile(&maps[mapnum], "_vm", vm_must_add_frozenbit);
			}
		}
	}
}


/*
 * transfer_relfile()
 *
 * Copy or link file from old cluster to new one.  If vm_must_add_frozenbit
 * is true, visibility map forks are converted and rewritten, even in link
 * mode.
 */
static void
transfer_relfile(FileNameMap *map, const char *type_suffix, bool vm_must_add_frozenbit)
{
	char		old_file[MAXPGPATH];
	char		new_file[MAXPGPATH];
	int			segno;
	char		extent_suffix[65];
	struct stat statbuf;		
		
	/*
	 * Now copy/link any related segments as well. Remember, PG breaks large
	 * files into 1GB segments, the first segment has no extension, subsequent
	 * segments are named relfilenode.1, relfilenode.2, relfilenode.3. copied.
	 */
	for (segno = 0;; segno++)
	{
		if (segno == 0)
			extent_suffix[0] = '\0';
		else
			snprintf(extent_suffix, sizeof(extent_suffix), ".%d", segno);

		snprintf(old_file, sizeof(old_file), "%s%s/%u/%u%s%s",
				 map->old_tablespace,
				 map->old_tablespace_suffix,
				 map->old_db_oid,
				 map->old_relfilenode,
				 type_suffix,
				 extent_suffix);
		snprintf(new_file, sizeof(new_file), "%s%s/%u/%u%s%s",
				 map->new_tablespace,
				 map->new_tablespace_suffix,
				 map->new_db_oid,
				 map->new_relfilenode,
				 type_suffix,
				 extent_suffix);

		/* Is it an extent, fsm, or vm file? */
		if (type_suffix[0] != '\0' || segno != 0)
		{
			/* Did file open fail? */
			if (stat(old_file, &statbuf) != 0)
			{
				/* File does not exist?  That's OK, just return */
				if (errno == ENOENT)
					return;
				else
					pg_fatal("error while checking for file existence \"%s.%s\" (\"%s\" to \"%s\"): %s\n",
							 map->nspname, map->relname, old_file, new_file,
							 strerror(errno));
			}

			/* If file is empty, just return */
			if (statbuf.st_size == 0)
				return;
		}

		unlink(new_file);

		/* Copying files might take some time, so give feedback. */
		pg_log(PG_STATUS, "%s", old_file);

		if (vm_must_add_frozenbit && strcmp(type_suffix, "_vm") == 0)
		{
			/* Need to rewrite visibility map format */
			pg_log(PG_VERBOSE, "rewriting \"%s\" to \"%s\"\n",
				   old_file, new_file);
			rewriteVisibilityMap(old_file, new_file, map->nspname, map->relname);
		}
		else if (user_opts.transfer_mode == TRANSFER_MODE_COPY)
		{
			pg_log(PG_VERBOSE, "copying \"%s\" to \"%s\"\n",
				   old_file, new_file);
			copyFile(old_file, new_file, map->nspname, map->relname);
		}
		else
		{
			pg_log(PG_VERBOSE, "linking \"%s\" to \"%s\"\n",
				   old_file, new_file);
			linkFile(old_file, new_file, map->nspname, map->relname);
		}
	}
}
