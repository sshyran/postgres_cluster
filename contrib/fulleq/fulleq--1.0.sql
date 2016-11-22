\echo Use "CREATE EXTENSION fulleq" to load this file. \quit

SET search_path = public;
-- For bool

CREATE OR REPLACE FUNCTION isfulleq_bool(bool, bool) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_bool(bool)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= bool,
	RIGHTARG	= bool,
	PROCEDURE	= isfulleq_bool,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS bool_fill_ops
 FOR TYPE bool USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_bool(bool);

-- For bytea

CREATE OR REPLACE FUNCTION isfulleq_bytea(bytea, bytea) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_bytea(bytea)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= bytea,
	RIGHTARG	= bytea,
	PROCEDURE	= isfulleq_bytea,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS bytea_fill_ops
 FOR TYPE bytea USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_bytea(bytea);

-- For char

CREATE OR REPLACE FUNCTION isfulleq_char(char, char) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_char(char)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= char,
	RIGHTARG	= char,
	PROCEDURE	= isfulleq_char,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS char_fill_ops
 FOR TYPE char USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_char(char);

-- For name

CREATE OR REPLACE FUNCTION isfulleq_name(name, name) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_name(name)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= name,
	RIGHTARG	= name,
	PROCEDURE	= isfulleq_name,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS name_fill_ops
 FOR TYPE name USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_name(name);

-- For int8

CREATE OR REPLACE FUNCTION isfulleq_int8(int8, int8) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_int8(int8)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= int8,
	RIGHTARG	= int8,
	PROCEDURE	= isfulleq_int8,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS int8_fill_ops
 FOR TYPE int8 USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_int8(int8);

-- For int2

CREATE OR REPLACE FUNCTION isfulleq_int2(int2, int2) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_int2(int2)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= int2,
	RIGHTARG	= int2,
	PROCEDURE	= isfulleq_int2,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS int2_fill_ops
 FOR TYPE int2 USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_int2(int2);

-- For int2vector

CREATE OR REPLACE FUNCTION isfulleq_int2vector(int2vector, int2vector) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_int2vector(int2vector)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= int2vector,
	RIGHTARG	= int2vector,
	PROCEDURE	= isfulleq_int2vector,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS int2vector_fill_ops
 FOR TYPE int2vector USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_int2vector(int2vector);

-- For int4

CREATE OR REPLACE FUNCTION isfulleq_int4(int4, int4) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_int4(int4)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= int4,
	RIGHTARG	= int4,
	PROCEDURE	= isfulleq_int4,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS int4_fill_ops
 FOR TYPE int4 USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_int4(int4);

-- For text

CREATE OR REPLACE FUNCTION isfulleq_text(text, text) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_text(text)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= text,
	RIGHTARG	= text,
	PROCEDURE	= isfulleq_text,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS text_fill_ops
 FOR TYPE text USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_text(text);

-- For oid

CREATE OR REPLACE FUNCTION isfulleq_oid(oid, oid) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_oid(oid)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= oid,
	RIGHTARG	= oid,
	PROCEDURE	= isfulleq_oid,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS oid_fill_ops
 FOR TYPE oid USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_oid(oid);

-- For xid

CREATE OR REPLACE FUNCTION isfulleq_xid(xid, xid) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_xid(xid)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= xid,
	RIGHTARG	= xid,
	PROCEDURE	= isfulleq_xid,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS xid_fill_ops
 FOR TYPE xid USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_xid(xid);

-- For cid

CREATE OR REPLACE FUNCTION isfulleq_cid(cid, cid) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_cid(cid)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= cid,
	RIGHTARG	= cid,
	PROCEDURE	= isfulleq_cid,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS cid_fill_ops
 FOR TYPE cid USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_cid(cid);

-- For oidvector

CREATE OR REPLACE FUNCTION isfulleq_oidvector(oidvector, oidvector) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_oidvector(oidvector)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= oidvector,
	RIGHTARG	= oidvector,
	PROCEDURE	= isfulleq_oidvector,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS oidvector_fill_ops
 FOR TYPE oidvector USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_oidvector(oidvector);

-- For float4

CREATE OR REPLACE FUNCTION isfulleq_float4(float4, float4) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_float4(float4)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= float4,
	RIGHTARG	= float4,
	PROCEDURE	= isfulleq_float4,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS float4_fill_ops
 FOR TYPE float4 USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_float4(float4);

-- For float8

CREATE OR REPLACE FUNCTION isfulleq_float8(float8, float8) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_float8(float8)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= float8,
	RIGHTARG	= float8,
	PROCEDURE	= isfulleq_float8,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS float8_fill_ops
 FOR TYPE float8 USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_float8(float8);

-- For abstime

CREATE OR REPLACE FUNCTION isfulleq_abstime(abstime, abstime) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_abstime(abstime)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= abstime,
	RIGHTARG	= abstime,
	PROCEDURE	= isfulleq_abstime,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS abstime_fill_ops
 FOR TYPE abstime USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_abstime(abstime);

-- For reltime

CREATE OR REPLACE FUNCTION isfulleq_reltime(reltime, reltime) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_reltime(reltime)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= reltime,
	RIGHTARG	= reltime,
	PROCEDURE	= isfulleq_reltime,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS reltime_fill_ops
 FOR TYPE reltime USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_reltime(reltime);

-- For macaddr

CREATE OR REPLACE FUNCTION isfulleq_macaddr(macaddr, macaddr) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_macaddr(macaddr)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= macaddr,
	RIGHTARG	= macaddr,
	PROCEDURE	= isfulleq_macaddr,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS macaddr_fill_ops
 FOR TYPE macaddr USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_macaddr(macaddr);

-- For inet

CREATE OR REPLACE FUNCTION isfulleq_inet(inet, inet) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_inet(inet)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= inet,
	RIGHTARG	= inet,
	PROCEDURE	= isfulleq_inet,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS inet_fill_ops
 FOR TYPE inet USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_inet(inet);

-- For cidr

CREATE OR REPLACE FUNCTION isfulleq_cidr(cidr, cidr) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_cidr(cidr)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= cidr,
	RIGHTARG	= cidr,
	PROCEDURE	= isfulleq_cidr,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS cidr_fill_ops
 FOR TYPE cidr USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_cidr(cidr);

-- For varchar

CREATE OR REPLACE FUNCTION isfulleq_varchar(varchar, varchar) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_varchar(varchar)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= varchar,
	RIGHTARG	= varchar,
	PROCEDURE	= isfulleq_varchar,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS varchar_fill_ops
 FOR TYPE varchar USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_varchar(varchar);

-- For date

CREATE OR REPLACE FUNCTION isfulleq_date(date, date) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_date(date)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= date,
	RIGHTARG	= date,
	PROCEDURE	= isfulleq_date,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS date_fill_ops
 FOR TYPE date USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_date(date);

-- For time

CREATE OR REPLACE FUNCTION isfulleq_time(time, time) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_time(time)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= time,
	RIGHTARG	= time,
	PROCEDURE	= isfulleq_time,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS time_fill_ops
 FOR TYPE time USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_time(time);

-- For timestamp

CREATE OR REPLACE FUNCTION isfulleq_timestamp(timestamp, timestamp) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_timestamp(timestamp)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= timestamp,
	RIGHTARG	= timestamp,
	PROCEDURE	= isfulleq_timestamp,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS timestamp_fill_ops
 FOR TYPE timestamp USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_timestamp(timestamp);

-- For timestamptz

CREATE OR REPLACE FUNCTION isfulleq_timestamptz(timestamptz, timestamptz) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_timestamptz(timestamptz)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= timestamptz,
	RIGHTARG	= timestamptz,
	PROCEDURE	= isfulleq_timestamptz,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS timestamptz_fill_ops
 FOR TYPE timestamptz USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_timestamptz(timestamptz);

-- For interval

CREATE OR REPLACE FUNCTION isfulleq_interval(interval, interval) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_interval(interval)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= interval,
	RIGHTARG	= interval,
	PROCEDURE	= isfulleq_interval,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS interval_fill_ops
 FOR TYPE interval USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_interval(interval);

-- For timetz

CREATE OR REPLACE FUNCTION isfulleq_timetz(timetz, timetz) 
RETURNS bool AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;

CREATE OR REPLACE FUNCTION fullhash_timetz(timetz)
RETURNS int4 AS 'MODULE_PATHNAME'
LANGUAGE C CALLED ON NULL INPUT IMMUTABLE;


CREATE OPERATOR == (
	LEFTARG		= timetz,
	RIGHTARG	= timetz,
	PROCEDURE	= isfulleq_timetz,
	COMMUTATOR	= '==',
	RESTRICT	= eqsel,
	JOIN		= eqjoinsel,
	HASHES
);

CREATE OPERATOR CLASS timetz_fill_ops
 FOR TYPE timetz USING hash AS
	OPERATOR	1	==,
	FUNCTION	1	fullhash_timetz(timetz);
