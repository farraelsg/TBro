<?php
/**
 * Creates a new job.
 * @param String $programname
 * @param String $database
 * @param Array $additional_data will be passed through 'till results
 * @param Array $paramters as $key=>$value
 * @param Array $queries
 * @return String UID
 */
function create_job($programname, $database, $additional_data = array(), $paramters = array(), $queries = array()) {
    try {
        //connect to the database
        $pdo = connect_queue_db();


        //builds an array with every 2*n-th parameter representing a parameter key and every 2*n+1-th parameter representing the respective value
        $parameters_prepared = array();
        foreach ($paramters as $key => $value) {
            $parameters_prepared[] = $key;
            $parameters_prepared[] = $value;
        }
        //builds a string like ARRAY[?,?],ARRAY[?,?] where the total count of questionmarks is is count($parameters)
        $parameter_qmarks = count($parameters_prepared) == 0 ? 'ARRAY[]' : implode(',', array_fill(0, count($parameters_prepared) / 2, 'ARRAY[?,?]'));
        //exit if we have no queries
        if (count($queries) == 0)
            return(array('status' => 'error', 'message' => 'No query sequence specified!'));


        //builds a string like '?,?,?' where the count of questionmarks is is count($queries)
        $query_qmarks = implode(',', array_fill(0, count($queries), '?'));

        //prepare the create_job statement
        $statement_create_job = $pdo->prepare('SELECT * FROM create_job(?,  ?, ?, ARRAY[' . $parameter_qmarks . '], ARRAY[' . $query_qmarks . ']);');
        //and execute it
        $statement_create_job->execute(array_merge(
                        array($programname, $database, json_encode($additional_data)), $parameters_prepared, $queries
        ));
        //rowcount should be 1 if job was started, else report an error
        if ($statement_create_job->rowCount() == 0) {
            return(array('status' => 'error', 'message' => 'Job could not be started! Please report this error including all parameters you used.'));
        }

        return array('status' => 'success', 'job_id' => $statement_create_job->fetchColumn());
    } catch (\PDOException $e) {
        //report errors
        return(array('status' => 'error', 'message' => 'Job could not be started: ' . $e->getMessage()));
    }
}

/**
 * gets job results.
 * @param String $job_uid
 * @return Array
 */
function get_job_results($job_uid) {
    try {
        //connect to the database
        $pdo = connect_queue_db();
        //prepare our get_job_results statement
        $statement_jobresults = $pdo->prepare('SELECT * FROM get_job_results(?);');
        //execute statement
        $statement_jobresults->execute(array($job_uid));
        $res = array();
        while ($row = $statement_jobresults->fetch(\PDO::FETCH_ASSOC)) {
            //we are the first row, store data that will be the same for every row
            if (empty($res)) {
                $res['job_status'] = $row['status'];
                $res['additional_data'] = json_decode($row['additional_data']);
                if ($row['status'] == 'NOT_PROCESSED') {
                    $statement_queuepos = $pdo->prepare('SELECT * FROM get_queue_position(?);');
                    $statement_queuepos->execute(array($_REQUEST['jobid']));
                    $pos = $statement_queuepos->fetch(\PDO::FETCH_ASSOC);
                    $res['queue_position'] = $pos['queue_position'];
                    $res['queue_length'] = $pos['queue_length'];
                }
            }
            //store the sub_query results in an array
            $res['processed_results'][] = array(
                'query' => $row['query'],
                'status' => $row['query_status'],
                'result' => $row['query_stdout'],
                'errors' => $row['query_stderr']
            );
        }
        //just return our data
        return $res;
    } catch (\PDOException $e) {
        //or die on error
        return array('status' => 'ERROR');
    }
}

/**
 *  Returns possible program/database combinations, based on $filter_string
 * @param String $filter_string might be an unique identifier for a release. If just one release exists, set to null-
 * @return Array
 */
function get_program_databases($filter_string=null) {
    try {
        //connect to the database
        $pdo = connect_queue_db();
        //prepare our get_programname_database statement
        $stm = $pdo->prepare('SELECT * FROM get_programname_database(?)');
        //and execute it
        $stm->execute(array($filter_string));
        $ret = array();
        while ($row = $stm->fetch(\PDO::FETCH_ASSOC)) {
            //put the rows into an array
            $ret[$row['programname']][] = $row['database_name'];
        }
        //and return it
        return $ret;
    } catch (\PDOException $e) {
        //on error, just return an empty json object
        return array();
    }
}

/*
 * splits fasta input to sequences for processing.
 * a simple 
 * <b>$queries = explode('>', $query); for ($queries as &$val) $val = '>'.$val;</b>
 * would do the same but we also test the sequences for valid format
 * fasta format according to http://blast.ncbi.nlm.nih.gov/blastcgihelp.shtml
 */

function split_fasta($query, $type) {

    $fasta_allowed = array();
    /*
      A  adenosine          C  cytidine             G  guanine
      T  thymidine          N  A/G/C/T (any)        U  uridine
      K  G/T (keto)         S  G/C (strong)         Y  T/C (pyrimidine)
      M  A/C (amino)        W  A/T (weak)           R  G/A (purine)
      B  G/T/C              D  G/A/T                H  A/C/T
      V  G/C/A              -  gap of indeterminate length
     */
    $fasta_allowed['nucl'] = 'ACGTNUKSYMWRBDHV-';
    /*
      A  alanine               P  proline
      B  aspartate/asparagine  Q  glutamine
      C  cystine               R  arginine
      D  aspartate             S  serine
      E  glutamate             T  threonine
      F  phenylalanine         U  selenocysteine
      G  glycine               V  valine
      H  histidine             W  tryptophan
      I  isoleucine            Y  tyrosine
      K  lysine                Z  glutamate/glutamine
      L  leucine               X  any
      M  methionine            *  translation stop
      N  asparagine            -  gap of indeterminate length
     */
    $fasta_allowed['prot'] = 'ABCDEFGHIKLMNPQRSTUVWYZX*-';

    $queries = array();

    //we have just one sequence without header
    if (strpos($query, '>') === FALSE) {
        $query = trim($query);
        if (preg_match('/^[0-9\\s' . $fasta_allowed[$type] . ']+$/im', $query))
            if (preg_match('/(\n\n|\r\n\r\n|\n\r\n\r)/im', $query)) {
                throw new Exception('FASTA sequence invalid! If you want to specify multiple sequences, add headers. If you want to query a single sequence, remove blank lines.');
            } else {
                $queries[] = ">query1\n" . $query;
            }
        else
            throw new Exception('FASTA sequence invalid!');
    } else {
        $require_next_line_header = true;
        $lines = explode(PHP_EOL, $query);
        foreach ($lines as $nr => $line) {
            $line = trim($line);
            // header line
            if (strpos($line, '>') === 0) {
                $require_next_line_header = false;
                $queries [] = "";
                $current = &$queries[count($queries) - 1];
                $current.=$line;
            }
            // content line, check for correct sequence
            else if (strlen($line) > 0) {
                if ($require_next_line_header)
                    throw new Exception(sprintf('Missing FASTA Header at line number %d', $nr));
                if (!preg_match('/^[' . $fasta_allowed[$type] . ']+$/i', $line))
                    throw new Exception(sprintf('FASTA sequence invalid in line %d!', $nr));
                $current.="\n" . $line;
            }
            //empty line, require a new header
            else {
                $require_next_line_header = true;
            }
        }
    }
    return $queries;
}

?>
