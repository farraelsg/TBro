<?php

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../constants.php';

class Importer_Annotations_Repeatmasker {

    /**
     * 
     * @global PDO $db db
     * @param string $filename filename
     * @throws Exception on DB Error
     * @throws ErrorException on DB Error
     */
    static function import($filename) {
        global $db;

        $regex = <<<EOF
{^ 
\d+[ ]
# 1320     = Smith-Waterman score of the match, usually complexity adjusted
\d+\.\d+[ ]
# 15.6     = % divergence = mismatches/(matches+mismatches) **
\d+\.\d+[ ]
# 6.2      = % of bases opposite a gap in the query sequence (deleted bp)
\d+\.\d+[ ]
# 0.0      = % of bases opposite a gap in the repeat consensus (inserted bp)
(?<name>\w+)[ ]
# HSU08988 = name of query sequence
(?<start>\d+)[ ]
# 6563     = starting position of match in query sequence
(?<end>\d+)[ ]
# 6781     = ending position of match in query sequence
\(\d+\)[ ]
# (22462)  = no. of bases in query sequence past the ending position of match
(?:[C+][ ])?
# C        = match is with the Complement of the repeat consensus sequence
(?<repeat_name>[\w()-]+)\#
# MER7A    = name of the matching interspersed repeat
(?<repeat_class>[\w()-]+)
(?:/(?<repeat_family>[\w()-]+))?[ ]
# DNA/MER2_type = the class of the repeat, in this case a DNA transposon fossil of the MER2 group (see below for list and references)
\(?\d+\)?[ ]
# (0)      = no. of bases in (complement of) the repeat consensus sequence prior to beginning of the match (0 means that the match extended all the way to the end of the repeat consensus sequence)
\(?\d+\)?[ ]
# 337      = starting position of match in repeat consensus sequence
\(?\d+\)?[ ]
# 104      = ending position of match in repeat consensus sequence
\d+
# 20       = unique identifier for individual insertions    
$}x
EOF;

        try {
            $db->beginTransaction();
            #shared parameters
            $param_name = null;
            $param_uniquename = null;
            $param_cvterm = null;
            $param_value = null;
            $param_fmin = null;
            $param_fmax = null;
            $param_srcfeature_uniq = null;

            $statement_insert_domain = $db->prepare('INSERT INTO feature (name, uniquename, type_id, organism_id) VALUES (:name, :uniquename, :type_id, :organism_id)');
            $statement_insert_domain->bindValue('type_id', CV_ANNOTATION_REPEATMASKER, PDO::PARAM_INT);
            $statement_insert_domain->bindValue('organism_id', DB_ORGANISM_ID, PDO::PARAM_INT);
            $statement_insert_domain->bindParam('name', &$param_name, PDO::PARAM_STR);
            $statement_insert_domain->bindParam('uniquename', &$param_uniquename, PDO::PARAM_STR);

            $statement_insert_featureloc = $db->prepare(sprintf('INSERT INTO featureloc (fmin, fmax, strand, feature_id, srcfeature_id) VALUES (:fmin, :fmax, :strand, currval(\'feature_feature_id_seq\'), (%s))', 'SELECT feature_id FROM feature WHERE uniquename=:srcfeature_uniquename LIMIT 1'));
            $statement_insert_featureloc->bindParam('fmin', &$param_fmin, PDO::PARAM_INT);
            $statement_insert_featureloc->bindParam('fmax', &$param_fmax, PDO::PARAM_INT);
            $statement_insert_featureloc->bindValue('strand', 1, PDO::PARAM_INT);
            $statement_insert_featureloc->bindParam('srcfeature_uniquename', &$param_srcfeature_uniq, PDO::PARAM_STR);

            $statement_annotate_domain = $db->prepare('INSERT INTO featureprop (feature_id, type_id, value) VALUES (currval(\'feature_feature_id_seq\'), :cvterm, :value)');
            $statement_annotate_domain->bindParam('cvterm', &$param_cvterm, PDO::PARAM_INT);
            $statement_annotate_domain->bindParam('value', &$param_value, PDO::PARAM_STR);

            $file = fopen($filename);
            while (($line = trim(fgets($file))) != false) {
                $matches = null;
                if (preg_match($regex, $line, &$matches)) {
                    for ($i = 0; $i < count($matches['name']); $i++) {
                        $param_name = sprintf("%s(%d-%d):%s#%s(%s)"
                                , $matches['name'][$i]
                                , $matches['start'][$i]
                                , $matches['end'][$i]
                                , $matches['repeat_name'][$i]
                                , $matches['repeat_class'][$i]
                                , $matches['repeat_family'][$i]
                        );
                        $param_uniquename = ASSEMBLY_PREFIX . $param_name;

                        $statement_insert_domain->execute();

                        $param_srcfeature_uniq = ASSEMBLY_PREFIX . $matches['name'][$i];
                        $param_fmin = $matches['start'];
                        $param_fmax = $matches['end'];
                        $statement_insert_featureloc->execute();

                        $param_cvterm = CV_REPEAT_NAME;
                        $param_value = $matches['repeat_name'][$i];
                        $statement_annotate_domain->execute();

                        $param_cvterm = CV_REPEAT_CLASS;
                        $param_value = $matches['repeat_class'][$i];
                        $statement_annotate_domain->execute();

                        if (!empty($matches['repeat_family'][$i])) {
                            $param_cvterm = CV_REPEAT_FAMILY;
                            $param_value = $matches['repeat_family'][$i];
                            $statement_annotate_domain->execute();
                        }
                    }
                } else {
                    echo "WARNING: Line does not match:\n\t$line\n";
                }
            }

            if (!$db->commit()) {
                $err = $db->errorInfo();
                throw new ErrorException($err[2], ERRCODE_TRANSACTION_NOT_COMPLETED, 1);
            }
        } catch (Exception $error) {
            $db->rollback();
            throw $error;
        }
    }

}

?>
