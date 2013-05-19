<?php

function _get_summary($field_name, $hd)
{
  $line = fgets($hd);

  $data = array();
  preg_match("/^$field_name = (.*)/", $line, $data)
  or die("Invalid summary file: " . $line);

  return split(',', $data[1]);
}

function get_summary()
{
  $hd = fopen(SUMMARY_FILE, 'r')
    or die("Cannot open summary file: " . SUMMARY_FILE);

  $avg_score = _get_summary('AVG SCORE', $hd);
  $avg_delta = _get_summary('AVG DELTA', $hd);

  fclose($hd);

  return array($avg_score, $avg_delta);
}

function get_info_files()
{
  foreach (glob(INFO_DIR . "/*") as $filename)
  {
    if (filesize($filename) > 0) // skip empty files
    {
      if (empty($first))
      {
        $first = $filename;
      }
      else if ($filename > $first)
      {
        $second = $first;
        $first = $filename;
      }
      else if (empty($second) || $filename > $second)
      {
        $second = $filename;
      }
    }
  }

  return array($first, $second);
}

function calc_score($reposts_count, $comments_count)
{
  return $reposts_count + 2 * $comments_count;
}

function _get_posts($info_file)
{
  $hd = fopen($info_file, 'r')
    or die("Cannot open info file: " . $info_file);
  $posts = array();
  
  while ($line = fgets($hd))
  {
    $line = trim($line);
    if (!empty($line) && preg_match('/\d+,\d+,\d+,\d\d\d\d-\d\d-\d\d.\d\d:\d\d:\d\d,\d+,\d+/', $line))
    {
      list($id,$reposts_count,$comments_count,$datetime,$epoch,$age)
        = split(',', $line);
      $posts[$id] = array($age, calc_score($reposts_count, $comments_count));
    }    
  }
  fclose($hd);
  
  return $posts;
}

function get_posts($first, $second)
{
  $old_posts = _get_posts($second);
  $posts = _get_posts($first);
  
  // Calc delta
  foreach ($posts as $id => $data)
  {
    if (isset($old_posts[$id]))
    {
      $old_score = $old_posts[$id][1];
      $score = $data[1];
      $delta = $score - $old_score;
      array_push($posts[$id], $delta);
    }
    else
    {
      array_push($posts[$id], 0);
    }
  }

  return $posts;
}

function update_final_score($posts, $avg_scores, $avg_deltas)
{
  $new_posts = array();
  foreach ($posts as $id => $data)
  {
    list($age, $score, $delta) = $data;
    if (isset($avg_scores[$age]) && isset($avg_deltas[$age]))
    {
      $avg_score = $avg_scores[$age];
      $avg_delta = $avg_deltas[$age];
      $new_posts[$id] = array($age, $score, $delta,
                      $score - $avg_score, $delta - $avg_delta);
    }
  }
  return $new_posts;
}

function _get_text($id)
{
  $ch = curl_init();
  
  curl_setopt($ch,CURLOPT_URL, "https://api.weibo.com/2/statuses/show.json?access_token=" . ACCESS_TOKEN . "&id=" . $id);
  curl_setopt($ch,CURLOPT_SSL_VERIFYPEER, FALSE);
  curl_setopt($ch,CURLOPT_RETURNTRANSFER, TRUE);
  $response = curl_exec($ch);
  $error = curl_error($ch);
  
  curl_close($ch);
  
  if ($error)
  {
    die("Failed to fetch text for " . $id . ", error: $error");
  }
  else
  {
    $post = json_decode($response, true);
    if (!empty($post) && isset($post['text']))
    {
      return $post['text'];
    }
    else
    {
      return "EMPTY RESPONSE";
    }
  }  
}

function get_text($id)
{
  $cache = TXT_DIR . "/$id";
  if (file_exists($cache))
  {
    return file_get_contents($cache);
  }
  else
  {
    $txt = _get_text($id);
    file_put_contents($cache, $txt);
    return $txt;
  }
}

?>