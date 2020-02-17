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

$stdout = fopen(__DIR__.'/../1Posts.csv','w');

ob_start();

fputcsv($stdout, array('title','content'));

for ($i=0;$i<100;$i++) {
    fputcsv($stdout, array($faker->asciify('******'), realTexts($chars=1050, $pars=4, $faker)));
}

ob_flush();
fclose($stdout);
