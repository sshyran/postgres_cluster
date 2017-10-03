import os
import unittest
from .helpers.ptrack_helpers import ProbackupTest, idx_ptrack
from time import sleep
from sys import exit


module_name = 'ptrack_cluster'


class SimpleTest(ProbackupTest, unittest.TestCase):

    @unittest.skip("skip")
    # @unittest.expectedFailure
    def test_ptrack_cluster_on_btree(self):
        fname = self.id().split('.')[3]
        node = self.make_simple_node(base_dir="{0}/{1}/node".format(module_name, fname),
            set_replication=True,
            initdb_params=['--data-checksums'],
            pg_options={'ptrack_enable': 'on', 'wal_level': 'replica', 'max_wal_senders': '2'})
        backup_dir = os.path.join(self.tmp_path, module_name, fname, 'backup')
        self.init_pb(backup_dir)
        self.add_instance(backup_dir, 'node', node)
        node.start()

        self.create_tblspace_in_node(node, 'somedata')

        # Create table and indexes
        node.safe_psql(
            "postgres",
            "create sequence t_seq; create table t_heap tablespace somedata as select i as id, nextval('t_seq') as t_seq, md5(i::text) as text, md5(repeat(i::text,10))::tsvector as tsvector from generate_series(0,256) i")
        for i in idx_ptrack:
            if idx_ptrack[i]['type'] != 'heap' and idx_ptrack[i]['type'] != 'seq':
                node.safe_psql("postgres", "create index {0} on {1} using {2}({3}) tablespace somedata".format(
                    i, idx_ptrack[i]['relation'], idx_ptrack[i]['type'], idx_ptrack[i]['column']))

        node.safe_psql('postgres', 'vacuum t_heap')
        node.safe_psql('postgres', 'checkpoint')

        for i in idx_ptrack:
            # get size of heap and indexes. size calculated in pages
            idx_ptrack[i]['old_size'] = self.get_fork_size(node, i)
            # get path to heap and index files
            idx_ptrack[i]['path'] = self.get_fork_path(node, i)
            # calculate md5sums of pages
            idx_ptrack[i]['old_pages'] = self.get_md5_per_page_for_fork(
                idx_ptrack[i]['path'], idx_ptrack[i]['old_size'])

        self.backup_node(backup_dir, 'node', node, options=['-j100', '--stream'])

        node.safe_psql('postgres', 'delete from t_heap where id%2 = 1')
        node.safe_psql('postgres', 'cluster t_heap using t_btree')
        node.safe_psql('postgres', 'checkpoint')

        for i in idx_ptrack:
            # get new size of heap and indexes. size calculated in pages
            idx_ptrack[i]['new_size'] = self.get_fork_size(node, i)
            # update path to heap and index files in case they`ve changed
            idx_ptrack[i]['path'] = self.get_fork_path(node, i)
            # calculate new md5sums for pages
            idx_ptrack[i]['new_pages'] = self.get_md5_per_page_for_fork(
                idx_ptrack[i]['path'], idx_ptrack[i]['new_size'])
            # get ptrack for every idx
            idx_ptrack[i]['ptrack'] = self.get_ptrack_bits_per_page_for_fork(
                node, idx_ptrack[i]['path'], [idx_ptrack[i]['old_size'], idx_ptrack[i]['new_size']])

            # compare pages and check ptrack sanity
            self.check_ptrack_sanity(idx_ptrack[i])

        # Clean after yourself
        self.del_test_dir(module_name, fname)

    @unittest.skip("skip")
    def test_ptrack_cluster_on_gist(self):
        fname = self.id().split('.')[3]
        node = self.make_simple_node(base_dir="{0}/{1}/node".format(module_name, fname),
            set_replication=True,
            initdb_params=['--data-checksums'],
            pg_options={'ptrack_enable': 'on', 'wal_level': 'replica', 'max_wal_senders': '2'})
        backup_dir = os.path.join(self.tmp_path, module_name, fname, 'backup')
        self.init_pb(backup_dir)
        self.add_instance(backup_dir, 'node', node)
        node.start()

        self.create_tblspace_in_node(node, 'somedata')

        # Create table and indexes
        node.safe_psql(
            "postgres",
            "create sequence t_seq; create table t_heap tablespace somedata as select i as id, nextval('t_seq') as t_seq, md5(i::text) as text, md5(repeat(i::text,10))::tsvector as tsvector from generate_series(0,256) i")
        for i in idx_ptrack:
            if idx_ptrack[i]['type'] != 'heap' and idx_ptrack[i]['type'] != 'seq':
                node.safe_psql("postgres", "create index {0} on {1} using {2}({3}) tablespace somedata".format(
                    i, idx_ptrack[i]['relation'], idx_ptrack[i]['type'], idx_ptrack[i]['column']))

        node.safe_psql('postgres', 'vacuum t_heap')
        node.safe_psql('postgres', 'checkpoint')

        for i in idx_ptrack:
            # get size of heap and indexes. size calculated in pages
            idx_ptrack[i]['old_size'] = self.get_fork_size(node, i)
            # get path to heap and index files
            idx_ptrack[i]['path'] = self.get_fork_path(node, i)
            # calculate md5sums of pages
            idx_ptrack[i]['old_pages'] = self.get_md5_per_page_for_fork(
                idx_ptrack[i]['path'], idx_ptrack[i]['old_size'])

        self.backup_node(backup_dir, 'node', node, options=['-j100', '--stream'])

        node.safe_psql('postgres', 'delete from t_heap where id%2 = 1')
        node.safe_psql('postgres', 'cluster t_heap using t_gist')
        node.safe_psql('postgres', 'checkpoint')

        for i in idx_ptrack:
            # get new size of heap and indexes. size calculated in pages
            idx_ptrack[i]['new_size'] = self.get_fork_size(node, i)
            # update path to heap and index files in case they`ve changed
            idx_ptrack[i]['path'] = self.get_fork_path(node, i)
            # calculate new md5sums for pages
            idx_ptrack[i]['new_pages'] = self.get_md5_per_page_for_fork(
                idx_ptrack[i]['path'], idx_ptrack[i]['new_size'])
            # get ptrack for every idx
            idx_ptrack[i]['ptrack'] = self.get_ptrack_bits_per_page_for_fork(
                node, idx_ptrack[i]['path'], [idx_ptrack[i]['old_size'], idx_ptrack[i]['new_size']])

            # compare pages and check ptrack sanity
            self.check_ptrack_sanity(idx_ptrack[i])

        # Clean after yourself
        self.del_test_dir(module_name, fname)

    # @unittest.skip("skip")
    def test_ptrack_cluster_on_btree_replica(self):
        fname = self.id().split('.')[3]
        master = self.make_simple_node(base_dir="{0}/{1}/master".format(module_name, fname),
            set_replication=True,
            initdb_params=['--data-checksums'],
            pg_options={'ptrack_enable': 'on', 'wal_level': 'replica', 'max_wal_senders': '2'})
        backup_dir = os.path.join(self.tmp_path, module_name, fname, 'backup')
        self.init_pb(backup_dir)
        self.add_instance(backup_dir, 'master', master)
        master.start()

        self.create_tblspace_in_node(master, 'somedata')
        self.backup_node(backup_dir, 'master', master, options=['--stream'])

        replica = self.make_simple_node(base_dir="{0}/{1}/replica".format(module_name, fname))
        replica.cleanup()

        self.restore_node(backup_dir, 'master', replica, options=['-T', '{0}={1}'.format(
            self.get_tblspace_path(master, 'somedata'), self.get_tblspace_path(replica, 'somedata_new'))])

        replica.append_conf('postgresql.auto.conf', 'port = {0}'.format(replica.port))
        self.add_instance(backup_dir, 'replica', replica)
        self.set_replica(master, replica, synchronous=True)
        self.set_archiving(backup_dir, 'replica', replica)
        replica.start()

        # Create table and indexes
        master.safe_psql(
            "postgres",
            "create sequence t_seq; create table t_heap tablespace somedata as select i as id, nextval('t_seq') as t_seq, md5(i::text) as text, md5(repeat(i::text,10))::tsvector as tsvector from generate_series(0,256) i")
        for i in idx_ptrack:
            if idx_ptrack[i]['type'] != 'heap' and idx_ptrack[i]['type'] != 'seq':
                master.safe_psql("postgres", "create index {0} on {1} using {2}({3}) tablespace somedata".format(
                    i, idx_ptrack[i]['relation'], idx_ptrack[i]['type'], idx_ptrack[i]['column']))

        #exit(1)
        master.safe_psql('postgres', 'vacuum t_heap')
        master.safe_psql('postgres', 'checkpoint')

        for i in idx_ptrack:
            # get size of heap and indexes. size calculated in pages
            idx_ptrack[i]['old_size'] = self.get_fork_size(replica, i)
            # get path to heap and index files
            idx_ptrack[i]['path'] = self.get_fork_path(replica, i)
            # calculate md5sums of pages
            idx_ptrack[i]['old_pages'] = self.get_md5_per_page_for_fork(
                idx_ptrack[i]['path'], idx_ptrack[i]['old_size'])

        self.backup_node(backup_dir, 'replica', replica, options=['-j100', '--stream',
            '--master-host=localhost', '--master-db=postgres', '--master-port={0}'.format(master.port)])

        master.safe_psql('postgres', 'delete from t_heap where id%2 = 1')
        master.safe_psql('postgres', 'cluster t_heap using t_btree')
        master.safe_psql('postgres', 'checkpoint')

        for i in idx_ptrack:
            # get new size of heap and indexes. size calculated in pages
            idx_ptrack[i]['new_size'] = self.get_fork_size(replica, i)
            # update path to heap and index files in case they`ve changed
            idx_ptrack[i]['path'] = self.get_fork_path(replica, i)
            # calculate new md5sums for pages
            idx_ptrack[i]['new_pages'] = self.get_md5_per_page_for_fork(
                idx_ptrack[i]['path'], idx_ptrack[i]['new_size'])
            # get ptrack for every idx
            idx_ptrack[i]['ptrack'] = self.get_ptrack_bits_per_page_for_fork(
                replica, idx_ptrack[i]['path'], [idx_ptrack[i]['old_size'], idx_ptrack[i]['new_size']])

            # compare pages and check ptrack sanity
            self.check_ptrack_sanity(idx_ptrack[i])

        # Clean after yourself
        self.del_test_dir(module_name, fname)

    #@unittest.skip("skip")
    def test_ptrack_cluster_on_gist_replica(self):
        fname = self.id().split('.')[3]
        master = self.make_simple_node(base_dir="{0}/{1}/master".format(module_name, fname),
            set_replication=True,
            initdb_params=['--data-checksums'],
            pg_options={'ptrack_enable': 'on', 'wal_level': 'replica', 'max_wal_senders': '2'})
        backup_dir = os.path.join(self.tmp_path, module_name, fname, 'backup')
        self.init_pb(backup_dir)
        self.add_instance(backup_dir, 'master', master)
        master.start()

        self.create_tblspace_in_node(master, 'somedata')
        self.backup_node(backup_dir, 'master', master, options=['--stream'])

        replica = self.make_simple_node(base_dir="{0}/{1}/replica".format(module_name, fname))
        replica.cleanup()

        self.restore_node(backup_dir, 'master', replica, options=['-T', '{0}={1}'.format(
            self.get_tblspace_path(master, 'somedata'), self.get_tblspace_path(replica, 'somedata_new'))])

        replica.append_conf('postgresql.auto.conf', 'port = {0}'.format(replica.port))
        self.add_instance(backup_dir, 'replica', replica)
        self.set_replica(master, replica, 'replica', synchronous=True)
        self.set_archiving(backup_dir, 'replica', replica)
        replica.start()

        # Create table and indexes
        master.safe_psql(
            "postgres",
            "create sequence t_seq; create table t_heap tablespace somedata as select i as id, nextval('t_seq') as t_seq, md5(i::text) as text, md5(repeat(i::text,10))::tsvector as tsvector from generate_series(0,256) i")
        for i in idx_ptrack:
            if idx_ptrack[i]['type'] != 'heap' and idx_ptrack[i]['type'] != 'seq':
                master.safe_psql("postgres", "create index {0} on {1} using {2}({3}) tablespace somedata".format(
                    i, idx_ptrack[i]['relation'], idx_ptrack[i]['type'], idx_ptrack[i]['column']))

        master.safe_psql('postgres', 'vacuum t_heap')
        master.safe_psql('postgres', 'checkpoint')

        for i in idx_ptrack:
            # get size of heap and indexes. size calculated in pages
            idx_ptrack[i]['old_size'] = self.get_fork_size(replica, i)
            # get path to heap and index files
            idx_ptrack[i]['path'] = self.get_fork_path(replica, i)
            # calculate md5sums of pages
            idx_ptrack[i]['old_pages'] = self.get_md5_per_page_for_fork(
                idx_ptrack[i]['path'], idx_ptrack[i]['old_size'])

        self.backup_node(backup_dir, 'replica', replica, options=['-j100', '--stream',
            '--master-host=localhost', '--master-db=postgres', '--master-port={0}'.format(master.port)])

        master.safe_psql('postgres', 'delete from t_heap where id%2 = 1')
        master.safe_psql('postgres', 'cluster t_heap using t_gist')
        master.safe_psql('postgres', 'checkpoint')
        #sleep(10)

        for i in idx_ptrack:
            # get new size of heap and indexes. size calculated in pages
            idx_ptrack[i]['new_size'] = self.get_fork_size(replica, i)
            # update path to heap and index files in case they`ve changed
            idx_ptrack[i]['path'] = self.get_fork_path(replica, i)
            # calculate new md5sums for pages
            idx_ptrack[i]['new_pages'] = self.get_md5_per_page_for_fork(
                idx_ptrack[i]['path'], idx_ptrack[i]['new_size'])
            # get ptrack for every idx
            idx_ptrack[i]['ptrack'] = self.get_ptrack_bits_per_page_for_fork(
                replica, idx_ptrack[i]['path'], [idx_ptrack[i]['old_size'], idx_ptrack[i]['new_size']])

            # compare pages and check ptrack sanity
            self.check_ptrack_sanity(idx_ptrack[i])

        # Clean after yourself
        self.del_test_dir(module_name, fname)