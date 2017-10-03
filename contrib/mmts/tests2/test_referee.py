#
# Based on Aphyr's test for CockroachDB.
#

import unittest
import time
import subprocess
import datetime
import docker
import warnings

from lib.bank_client import MtmClient
from lib.failure_injector import *
from lib.test_helper import *


class MajorTest(unittest.TestCase, TestHelper):

    @classmethod
    def setUpClass(cls):
        subprocess.check_call(['docker-compose',
            '-f', 'support/two_nodes.yml',
            'up',
            '--force-recreate',
            '--build',
            '-d'])

        # XXX: add normal wait here
        time.sleep(TEST_SETUP_TIME)

        cls.client = MtmClient([
            "dbname=regression user=postgres host=127.0.0.1 port=15432",
            "dbname=regression user=postgres host=127.0.0.1 port=15433"
        ], n_accounts=1000)
        cls.client.bgrun()

        # create extension on referee
        cls.nodeExecute("dbname=regression user=postgres host=127.0.0.1 port=15435", ['create extension referee'])

    @classmethod
    def tearDownClass(cls):
        print('tearDown')
        cls.client.stop()

        time.sleep(TEST_STOP_DELAY)

        if not cls.client.is_data_identic():
            raise AssertionError('Different data on nodes')

        if cls.client.no_prepared_tx() != 0:
            raise AssertionError('There are some uncommitted tx')

        # XXX: check nodes data identity here
        # subprocess.check_call(['docker-compose','down'])

    def setUp(self):
        warnings.simplefilter("ignore", ResourceWarning)
        time.sleep(20)
        print('Start new test at ',datetime.datetime.utcnow())

    def tearDown(self):
        print('Finish test at ',datetime.datetime.utcnow())

    def test_node_crash(self):
        print('### test_node_crash ###')

        aggs_failure, aggs = self.performFailure(CrashRecoverNode('node2'))

        self.assertCommits(aggs_failure[:1])
        self.assertNoCommits(aggs_failure[1:])
        self.assertIsolation(aggs_failure)

        self.assertCommits(aggs)
        self.assertIsolation(aggs)


    def test_partition_referee(self):
        print('### test_partition_referee ###')

        aggs_failure, aggs = self.performFailure(SingleNodePartition('node2'))

        self.assertCommits(aggs_failure[:1])
        self.assertNoCommits(aggs_failure[1:])
        self.assertIsolation(aggs_failure)

        self.assertCommits(aggs)
        self.assertIsolation(aggs)

    def test_double_failure_referee(self):
        print('### test_double_failure_referee ###')

        aggs_failure, aggs = self.performFailure(SingleNodePartition('node2'))

        self.assertCommits(aggs_failure[:1])
        self.assertNoCommits(aggs_failure[1:])
        self.assertIsolation(aggs_failure)

        self.assertCommits(aggs)
        self.assertIsolation(aggs)

        aggs_failure, aggs = self.performFailure(SingleNodePartition('node1'))

        self.assertNoCommits(aggs_failure[:1])
        self.assertCommits(aggs_failure[1:])
        self.assertIsolation(aggs_failure)

        self.assertCommits(aggs)
        self.assertIsolation(aggs)


if __name__ == '__main__':
    unittest.main()
