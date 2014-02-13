<?php
if(!function_exists('_db_config')){
  function _db_config($p){
    $t = parse_url($_SERVER['MYSQL_DATABASE']);
    return trim($t[$p], '/');
  }
}

echo 'Hello, world!';

echo '<pre>';
print_R(all('select * from users'));

###########


function db(){
  static $db = null;
  if(is_null($db)){
    $db = new PDO('mysql:host='._db_config('host').';dbname='._db_config('path'), _db_config('user'), _db_config('pass'));
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    $db->query('set names utf8');
  }
  return $db;
}

function q($t){
  return db()->quote($t);
}
function query($q){
  return db()->query($q);
}
function one($q){
  return query($q)->fetch();
}
function all($q){
  return query($q)->fetchAll();
}

