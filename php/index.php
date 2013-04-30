<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Weibo News / 新闻聚光灯</title>
<link rel="stylesheet" href="bootstrap/css/bootstrap.css">
<style type="text/css">
.post {
  border-bottom: 1px grey dotted;
  margin-bottom: 1em;
  overflow: hidden;
  height: 120px;
}
h1 {
  font-family: Arial, "Microsoft YaHei", sans-serif;
  font-size: 24px;
  text-align: center;
  border-bottom: 1px grey dotted;
  padding-bottom: 0.5em;
}
.txt {
  font-family: "Consolas", "Simsun", sans-serif;
  font-size: 12px;
}
.info {
  float: left;
  width: 60px;
  height: 100%;
  text-align: center;
  font-family: "Consolas", sans-serif;
  font-size: 12px;
  padding-top: 20px;
}
.debug {
  font-family: "Consolas", sans-serif;
  font-size: 9px;
  color: silver;
}
</style>
</head>
<body>
  <div class="container">
    <div class="row">
      <div class="span3">&nbsp;</div>
      <div class="span6">
        <h1>Weibo News / 新闻聚光灯</h1>
      </div>
      <div class="span3">&nbsp;</div>
    </div>
<?php

require_once('config.php');
require_once('functions.php');


list($avg_score, $avg_delta) = get_summary();
list($first, $second) = get_info_files();

$posts = get_posts($first, $second);
$posts = update_final_score($posts, $avg_score, $avg_delta);

uasort($posts, function($a, $b) { return $b[3] - $a[3]; });

$i = 0;
foreach ($posts as $id => $data)
{
  list($age,$total_score,$total_delta,$score,$delta) = $data;
  ?>
  <div class="row">
    <div class="span3">&nbsp;</div>
    <div class="span6">
      <div class="post">
        <div class="info">
          <div class="delta"><?php echo $delta > 0 ? '<img src="images/arrow-alt-up.png"></img>' : '<img src="images/arrow-alt-down.png"></img>'?></div>
          <div class="score"><?php echo $score?></div>
        </div>
        <div class="txt">
          <?php 
            $txt = get_text($id);
            $txt = preg_replace('/(http:\/\/t\.cn\/[0-9A-Za-z]*)/', '<a href="$1">$1</a>', $txt);
            echo $txt;
          ?>
        </div>
        <div class="debug">
        AGE:<?php echo $age?>
        TS:<?php echo $total_score?>
        TD:<?php echo $total_delta?>
        S:<?php echo $score?>
        D:<?php echo $delta?>
        </div>
      </div>
    </div>
    <div class="span3">&nbsp;</div>
  </div>
<?php   
  ++$i;
  if ($i >= POST_COUNT)
  {
    break;
  }
}

?>
</div>
</body>
<?php 
  // Debug output
  print "<!-- AVG SCORE = " . join(',', $avg_score) . " -->\n";
  print "<!-- AVG DELTA = " . join(',', $avg_delta) . " -->\n";
  print "<!-- FST = $first -->\n";
  print "<!-- SND = $second -->\n";
  print "<!--\n";
  foreach ($posts as $id => $data)
  {
    print "  $id," . join(',', $data) . "\n";
  }
  print "-->\n";
?>
</html>