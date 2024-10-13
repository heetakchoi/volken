#!/usr/bin/perl

use strict;
use warnings;

use lib "../lib";
use Volken::Http;
use Volken::Https;


my $service_key =
    # "vnG+yHsHkgZws5GKGIkUrBkyl7mRN1sGUnntd2NIU11PXe+vZn0GFiWiTFaqDrjOvmC99PPTDkr5uG1kJgzICw==";
    "vnG%2ByHsHkgZws5GKGIkUrBkyl7mRN1sGUnntd2NIU11PXe%2BvZn0GFiWiTFaqDrjOvmC99PPTDkr5uG1kJgzICw%3D%3D";

my $isin_naver = "KR7035420009";
my $isin_kal = "KR7003490000";

my $https = Volken::Https->new;
$https->host("apis.data.go.kr")
    ->url("/1160100/service/GetStockSecuritiesInfoService/getStockPriceInfo")
    ->header("Host", "apis.data.go.kr")
    ->param("serviceKey", $service_key)
    ->param("numOfRows", 1)
    ->param("pageNo", 1)
    ->param("isinCd", $isin_naver)
    ;
my $result = $https->get;

printf "\n%s\n", $result;
