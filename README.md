# dokuro

## Что это

Обёртка вокруг вагранта, позволяющая удобно подключать в работу заранее подготовленные
php сайты.

Те же самые сайты, на боевом сервере, разворачиваются под управлением [sakura](https://github.com/Bubujka/sakura)


## Как начать работать

На компьютере разработчика должны быть:

- virtualbox
- vagrant
- git

После этого:

- Клонируем [dokuro](http://github.com/Bubujka/dokuro)
- В папку prj разворачиваем нужные репозитории для разработки
  Для некоторых проектов нужна база MySQL - создаём файл prj/$prjname/dump.sql
  или кладём туда изначальный дамп.
- Запускаем команду 'vagrant up'

### При добавлении нового проекта

Нужно запустить:
```sh
./bin/reload
```

## Как должен выглядеть проект для dokuro

В папке [prj/example](https://github.com/Bubujka/dokuro/tree/master/prj/example) находится пример сайта с базой данных.

### CNAME

Файл содержащий домен/домены для боевого сервера (используется sakura)

### nginx.conf

Как минимум следующего вида:

```nginx
index index.php;
include php_fastcgi;
```

### dump.sql или dump.sql.gz

Файл содержащий дамп базы. Им будет заполнена база при переконфигурировании dokuro.


## Домен dokuro.ru

Сайты становятся доступны по адресу http://$prjname.dokuro.ru/

Домен dokuro.ru и все его поддомены ссылаются на ip адрес 192.168.56.66,
по этому же адресу располагается виртуальная машина.

## Свои команды для установки

Можно создать файл install и в него занести всё что нужно разработчику.
Он будет выполнен в конце установки, перед переконфигурированием проектов.

## MySQL

Настройки MySQL передаются через переменные окружения сайту. В php их возможно использовать следующим образом:

```php
<?php
if(!function_exists('_db_config')){
  function _db_config($p){
    $t = parse_url($_SERVER['MYSQL_DATABASE']);
    return trim($t[$p], '/');
  }
}

'mysql' => array(
  'driver'   => 'mysql',
  'host'     => _db_config('host'),
  'database' => _db_config('path'),
  'username' => _db_config('user'),
  'password' => _db_config('pass'),
  'charset'  => 'utf8',
  'prefix'   => '',
),
```

## composer

Он установлен и его можно использовать, прописав в install файл проекта.

