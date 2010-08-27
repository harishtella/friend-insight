<?php 
require_once('DB.php');

$db = new DB();



//$db->new_ftest_row('5555','2','mashblah','zipfoo');
$db->add_ftest_result('1234','1','wewonbaby');
$foo = $db->get_result('1234', '1');
//$db->add_ftest_result('5555','2','goodshitmang');

print_r($foo);

$db->close();

?>
