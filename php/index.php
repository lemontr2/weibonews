<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Weibo News / 新闻聚光灯</title>
<style type="text/css">
.main {
  width: 460px;
  margin-right: auto;
  margin-left: auto;
}
a {
  color: #0088cc;
  text-decoration: none;
}
.post {
  border-bottom: 1px grey dotted;
  margin-bottom: .5em;
  padding-bottom: .5em;
  overflow: hidden;
  padding-left: 15px;
  padding-right: 15px;
}
h1 {
  font-family: Arial, "Microsoft YaHei", sans-serif;
  font-size: 24px;
  text-align: center;
  border-bottom: 1px grey dotted;
  padding-bottom: 1em;
  margin-bottom: .5em;
}
.txt {
  font-family: "Consolas", "nsimsun", monospace;
  font-size: 12px;
  line-height: 1.8em;
}
.debug {
  font-family: "Consolas", monospace;
  font-size: 9px;
  color: silver;
  line-height: 1em;
  margin-top: 3px;
}
.score {
  color: #555;
  
}
</style>
</head>
<body>
  <div class="main">
    <h1>Weibo News / 新闻聚光灯</h1>
<?php
date_default_timezone_set('Asia/Shanghai');

require_once('token.php');
define('UID', '1618051664'); // breakingnews
define('LIMIT', 20); // How many posts to show
define('POST_COUNT', 100); // How many posts to fetch
define('POST_COUNT_2', 50); // How many posts we need from UID

function calc_score($reposts_count, $comments_count)
{
  return $reposts_count + 2 * $comments_count;
}

function adjust_score($age, $score)
{
  static $AVG = array(
1117, 2007, 2464, 2752, 2954, 3144, 3238, 3383, 3430, 3393, 3551, 3646, 3746,
3806, 3935, 4006, 3901, 3947, 3903, 4031, 4051, 4000, 4048, 4180, 4262, 4437,
4263, 4324, 4476, 4415, 4620, 4707, 4503, 4593, 4640, 4749, 4986, 4758, 4934,
4928, 4963, 4757, 4776, 4896, 4684, 4773, 4607, 4587, 4768, 4675, 4715, 4531,
4575, 4313, 4225, 4184, 4434, 4593, 3044, 3755, 3955, 4085, 3408, 4549, 3557,
2653, 4666, 4192);
  
  static $MAX = 5000;
  
  if (isset($AVG[$age]))
  {
    return $score - $AVG[$age];
  }
  else
  {
    return $score - $MAX;
  }
}

function parse_datetime($str)
{
  $parts = date_parse($str);
  if ($parts)
  {
   list($h,$m,$s,$month,$d,$y) = array(
                  $parts['hour'], $parts['minute'], $parts['second'],
                  $parts['month'], $parts['day'], $parts['year']);
   return mktime($h,$m,$s,$month,$d,$y);
  }
  else
  {
    die("Failed to parse datetime, str=\"$str\"");
  }
}

function get_posts()
{
  $ch = curl_init();
  
  curl_setopt($ch,CURLOPT_URL, "https://api.weibo.com/2/statuses/friends_timeline.json"
                  . "?access_token=" . ACCESS_TOKEN
                  . "&count=" . POST_COUNT
                  . "&feature=1");
  curl_setopt($ch,CURLOPT_SSL_VERIFYPEER, FALSE);
  curl_setopt($ch,CURLOPT_RETURNTRANSFER, TRUE);
  $response = curl_exec($ch);
  $error = curl_error($ch);
  
  curl_close($ch);
  
  if ($error)
  {
    die("Failed to fetch posts: $error");
  }
  else
  {
    $now = time();
    $posts = json_decode($response, true);
    if (!empty($posts))
    {
      if (isset($posts['statuses']))
      {
        $ret = array();
        $i = 0;
        foreach ($posts['statuses'] as $post)
        {
          if ($post['user']['id'] == UID)
          {
            $age = intval(($now - parse_datetime($post['created_at'])) / 3600);
            $ts = calc_score($post['reposts_count'], $post['comments_count']);
            $s = adjust_score($age, $ts);
            $txt = $post['text'];
            array_push($ret, array($age, $ts, $s, $txt));
            ++$i;
          }
          if ($i >= POST_COUNT_2)
          {
            break;
          }
        }
        return $ret;
      }
      if (isset($posts['error']))
      {
        error_log("Failed to fetch posts: " . $posts['error']);
        return array();
      }
    }
    else
    {
      return array();
    }
  }
}

function _sort_by_score($a, $b) {
  return $b[2] - $a[2];
}

$posts = get_posts();
uasort($posts, '_sort_by_score');

$i = 0;
foreach ($posts as $post)
{
  list($age,$total_score,$score,$txt) = $post;
  ?>
      <div class="post">
        <div class="txt">
          <?php 
            echo preg_replace('/(http:\/\/t\.cn\/[0-9A-Za-z]*)/', '<a href="$1">$1</a> ', $txt);
          ?>
        </div>
        <div class="debug">
        AGE:<?php echo $age?>
        TS:<?php echo $total_score?>
        <span class="score">S:<?php echo $score?></span>
        </div>
      </div>
<?php   
  ++$i;
  if ($i >= LIMIT)
  {
    break;
  }
}

?>
</div>
</body>
</html>
