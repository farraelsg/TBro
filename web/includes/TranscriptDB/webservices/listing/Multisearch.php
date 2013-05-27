<?php

namespace webservices\listing;

use \PDO as PDO;

class Multisearch extends \WebService {

    public function execute($querydata) {
        global $db;
        $species = intval($_REQUEST['species']);
        $import = $_REQUEST['release'];
        $longterm = $_REQUEST['longterm'];
        $terms = preg_split('/[,\s]+/m', $longterm, -1, PREG_SPLIT_NO_EMPTY);
        $qmarks = implode(',', array_fill(0, count($terms), '?'));
        $values = array_merge(array($species, $import), $terms);
        
#UI hint
        if (false)
            $db = new PDO();

        $query_get_features = <<<EOF
SELECT * FROM multisearch(?, ?, ARRAY[$qmarks]::varchar[])
EOF;

        $stm_get_features = $db->prepare($query_get_features);

        $data = array('results' => array());

        $stm_get_features->execute($values);
        while ($feature = $stm_get_features->fetch(PDO::FETCH_ASSOC)) {
            $data['results'][$feature['feature_id']] = array(
                'name' => $feature['feature_name'].(!empty($feature['synonym_name'])?sprintf(' (%s)',$feature['synonym_name']):'')
                , 'type' => $feature['type_id'] == CV_UNIGENE ? 'unigene' : 'isoform'
                , 'feature_id' => $feature['feature_id']
            );
        }

        return $data;
    }

}

?>

