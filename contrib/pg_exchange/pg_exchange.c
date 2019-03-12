/* ------------------------------------------------------------------------
 *
 * pg_exchange.c
 *		This module Adds custom node called EXCHANGE and rules for planner.
 *		Now planner can made some operations uver the partitioned relations
 *
 * Copyright (c) 2018, Postgres Professional
 *
 * ------------------------------------------------------------------------
 */

#include "postgres.h"

#include "catalog/pg_class.h"
#include "common.h"
#include "common/base64.h"
#include "dmq.h"
#include "exchange.h"
#include "hooks.h"
#include "libpq/libpq-be.h"
#include "miscadmin.h"
#include "nodeDistPlanExec.h"
#include "nodeDummyscan.h"
#include "nodes/nodes.h"
#include "utils/builtins.h"
#include "utils/guc.h"
#include "utils/memutils.h"
#include "utils/plancache.h"
#include "utils/snapmgr.h"


PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(init_pg_exchange);
PG_FUNCTION_INFO_V1(pg_exec_plan);


#define DMQ_CONNSTR_MAX_LEN 150


void _PG_init(void);
static void deserialize_plan(char **squery, char **splan, char **sparams);
static void exec_plan(char *squery, PlannedStmt *pstmt, ParamListInfo paramLI, const char *serverName);

static Size
shmem_size(void)
{
	Size	size = 0;

	size = add_size(size, sizeof(ExchangeSharedState));
	size = add_size(size, hash_estimate_size(1024,
											 sizeof(DMQDestinations)));
	return MAXALIGN(size);
}

/*
 * Module load/unload callback
 */
void
_PG_init(void)
{
	EXCHANGE_Init_methods();
	DUMMYSCAN_Init_methods();
	EXEC_Hooks_init();
	dmq_init("pg_exchange");

	RequestAddinShmemSpace(shmem_size());
	RequestNamedLWLockTranche("pg_exchange", 1);
}

Datum
init_pg_exchange(PG_FUNCTION_ARGS)
{
	elog(LOG, "END OF INIT");
	PG_RETURN_VOID();
}

Datum
pg_exec_plan(PG_FUNCTION_ARGS)
{
	char	*squery = TextDatumGetCString(PG_GETARG_DATUM(0)),
			*splan = TextDatumGetCString(PG_GETARG_DATUM(1)),
			*sparams = TextDatumGetCString(PG_GETARG_DATUM(2)),
			*serverName = TextDatumGetCString(PG_GETARG_DATUM(3)),
			*start_address;
	PlannedStmt *pstmt;
	ParamListInfo paramLI;

	deserialize_plan(&squery, &splan, &sparams);

	pstmt = (PlannedStmt *) stringToNode(splan);

	/* Deserialize parameters of the query */
	start_address = sparams;
	paramLI = RestoreParamList(&start_address);

	exec_plan(squery, pstmt, paramLI, serverName);
	PG_RETURN_VOID();
}

/*
 * Decode base64 string into C-string and return it at same pointer
 */
static void
deserialize_plan(char **squery, char **splan, char **sparams)
{
	char	*dec_query,
			*dec_plan,
			*dec_params;
	int		dec_query_len,
			len,
			dec_plan_len,
			dec_params_len;

	dec_query_len = pg_b64_dec_len(strlen(*squery));
	dec_query = palloc0(dec_query_len + 1);
	len = pg_b64_decode(*squery, strlen(*squery), dec_query);
	Assert(dec_query_len >= len);

	dec_plan_len = pg_b64_dec_len(strlen(*splan));
	dec_plan = palloc0(dec_plan_len + 1);
	len = pg_b64_decode(*splan, strlen(*splan), dec_plan);
	Assert(dec_plan_len >= len);

	dec_params_len = pg_b64_dec_len(strlen(*sparams));
	dec_params = palloc0(dec_params_len + 1);
	len = pg_b64_decode(*sparams, strlen(*sparams), dec_params);
	Assert(dec_params_len >= len);

	*squery = dec_query;
	*splan = dec_plan;
	*sparams = dec_params;
}
#include "tcop/tcopprot.h"
static void
exec_plan(char *squery, PlannedStmt *pstmt, ParamListInfo paramLI, const char *serverName)
{
	CachedPlanSource	*psrc;
	CachedPlan			*cplan;
	QueryDesc			*queryDesc;
	DestReceiver		*receiver;
	int					eflags = 0;
	Oid					*param_types = NULL;

	Assert(squery && pstmt && paramLI);
	debug_query_string = strdup(squery);
	psrc = CreateCachedPlan(NULL, squery, NULL);

	if (paramLI->numParams > 0)
	{
		int i;

		param_types = palloc(sizeof(Oid) * paramLI->numParams);
		for (i = 0; i < paramLI->numParams; i++)
			param_types[i] = paramLI->params[i].ptype;
	}
	CompleteCachedPlan(psrc, NIL, NULL, param_types, paramLI->numParams, NULL,
								NULL, CURSOR_OPT_GENERIC_PLAN, false);

	SetRemoteSubplan(psrc, pstmt);
	cplan = GetCachedPlan(psrc, paramLI, false, NULL);

	receiver = CreateDestReceiver(DestLog);

	PG_TRY();
	{
		lcontext context;
		queryDesc = CreateQueryDesc(pstmt,
									squery,
									GetActiveSnapshot(),
									InvalidSnapshot,
									receiver,
									paramLI, NULL,
									0);

		ExecutorStart(queryDesc, eflags);

		context.estate = queryDesc->estate;
		context.eflags = eflags;
		context.servers = NIL;
		localize_plan(queryDesc->planstate, &context);
		EstablishDMQConnections(&context, serverName);

		PushActiveSnapshot(queryDesc->snapshot);
		ExecutorRun(queryDesc, ForwardScanDirection, 0, true);
		PopActiveSnapshot();
		ExecutorFinish(queryDesc);
		ExecutorEnd(queryDesc);
		FreeQueryDesc(queryDesc);
	}
	PG_CATCH();
	{
		elog(INFO, "BAD QUERY: '%s'.", squery);
		ReleaseCachedPlan(cplan, false);
		PG_RE_THROW();
	}
	PG_END_TRY();

	receiver->rDestroy(receiver);
	ReleaseCachedPlan(cplan, false);
}