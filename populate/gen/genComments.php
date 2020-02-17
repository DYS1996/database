<?php
require_once 'vendor/autoload.php';

function realTexts($chars, $pars, $gen) {
    $txt = "";
    for ($i=0;$i<$pars;$i++) {
        $txt .= $gen->realText($maxNbChars = $chars);
        if ($i !== $pars - 1) {
            $txt .= "\n";
        }
    }
    return $txt;
}


$faker = Faker\Factory::create();

$stdout = fopen(__DIR__.'/../2Comments.csv','w');

ob_start();

fputcsv($stdout, array('postID','content','authorEmail'));

for ($i=0;$i<100;$i++) {
    fputcsv($stdout, array($faker->numberBetween($min=1,$max=100), realTexts($chars=20, $pars=2, $faker), $faker->email()));
}

ob_flush();
fclose($stdout);
