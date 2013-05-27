<?php

namespace webservices\details;

use \PDO as PDO;

class Isoform extends \WebService {

    public function execute($querydata) {
        global $db;
        $constant = 'constant';

#UI hint
        if (false)
            $db = new PDO();

        $param_isoform_feature_id = $querydata['query1'];
        $param_isoform_id = null;
        $query_get_isoforms = <<<EOF
SELECT DISTINCT ON (isoform.feature_id, dbxref.dbxref_id)
        isoform.*, dbxref.accession AS import, organism.common_name AS organism_name
    FROM feature AS isoform
        JOIN dbxref ON (isoform.dbxref_id = dbxref.dbxref_id AND dbxref.db_id = {$constant('DB_ID_IMPORTS')})
        JOIN organism ON (isoform.organism_id = organism.organism_id)
    WHERE isoform.feature_id = :isoform_id
        AND isoform.type_id = {$constant('CV_ISOFORM')}
    LIMIT 1;
EOF;
        $stm_get_isoforms = $db->prepare($query_get_isoforms);
        $stm_get_isoforms->bindValue('isoform_id', $param_isoform_feature_id);

        
        

        $query_get_desc = <<<EOF
SELECT
  *
FROM
  featureprop
WHERE
  featureprop.feature_id = :isoform_id AND
  featureprop.type_id = {$constant('CV_ANNOTATION_DESC')}
EOF;

        $stm_get_desc = $db->prepare($query_get_desc);
        $stm_get_desc->bindParam('isoform_id', $param_isoform_id);


        $query_get_unigene = <<<EOF
SELECT unigene.*
    FROM feature_relationship, feature AS unigene
    WHERE unigene.feature_id = feature_relationship.object_id
    AND :isoform_id = feature_relationship.subject_id    
    AND unigene.type_id = {$constant('CV_UNIGENE')}
EOF;

        $stm_get_unigene = $db->prepare($query_get_unigene);
        $stm_get_unigene->bindParam('isoform_id', $param_isoform_id);







        $return = array();

        $stm_get_isoforms->execute();
        if (($isoform = $stm_get_isoforms->fetch(PDO::FETCH_ASSOC)) !== false) {
            $param_isoform_id = $isoform['feature_id'];


            $stm_get_unigene->execute();

            if (($unigene = $stm_get_unigene->fetch(PDO::FETCH_ASSOC)) !== false) {
                $isoform['unigene'] = $unigene;
            }

            $stm_get_desc->execute();
            while ($desc = $stm_get_desc->fetch(PDO::FETCH_ASSOC)) {
                $isoform['description'][] = $desc;
            }

            $return['isoform'] = &$isoform;
        }

        return $return;
    }

}

?>