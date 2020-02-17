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

$stdout = fopen(__DIR__.'/../3Tags.csv','w');

ob_start();

fputcsv($stdout, array('postID','tag'));

for ($i=0;$i<100;$i++) {
    fputcsv($stdout, array($faker->numberBetween($min=1,$max=100), $faker->asciify('****') ));
}

ob_flush();
fclose($stdout);
