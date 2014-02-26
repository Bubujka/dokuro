<?php
if(isset($_GET['make_default'])){
  foreach(glob('/etc/nginx/sites-enabled/*') as $pth){
    file_put_contents($pth, str_replace('listen *:80 default_server', 'listen *:80', file_get_contents($pth)));
  }
  $pth = '/etc/nginx/sites-enabled/'.$_GET['make_default'];
  file_put_contents($pth , str_replace('listen *:80', 'listen *:80 default_server', file_get_contents($pth)));

  system('sudo /usr/sbin/service nginx reload > /dev/null');
  #header('Location: /');
}
?>
<html>

<?php
foreach(glob('/etc/nginx/sites-enabled/*') as $pth){
  $t = file_get_contents($pth);
  $name = basename($pth);
  if(strstr($t, 'listen *:80 default_server') !== false){
    echo '<b>'.$name.'</b>';
  }else
    echo '<a href="http://admin.dokuro.ru/?make_default='.$name.'">'.$name.'</a>';
  echo '<br>';
}

