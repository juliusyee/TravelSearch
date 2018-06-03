<?php
    if (isset($_GET["token"]))
    {
        $MapAPI = "AIzaSyClGpcvf2I4kf8H7dmk1VA7EKv2INPjqTg";
        $next_page_token = $_GET["token"];
        $nextURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=".$next_page_token."&key=".$MapAPI;
        $nextJSON = get_object_vars(json_decode(file_get_contents($nextURL)));
        echo (json_encode($nextJSON,JSON_PRETTY_PRINT));
     }
    
    if (isset($_GET["placeID"]))
    {
        $MapAPI = "AIzaSyClGpcvf2I4kf8H7dmk1VA7EKv2INPjqTg";
        $placeid = $_GET["placeID"];
        $detailsURL = "https://maps.googleapis.com/maps/api/place/details/json?placeid=".$placeid."&key=".$MapAPI;
        $detailsJSON = get_object_vars(json_decode(file_get_contents($detailsURL)));
        echo (json_encode($detailsJSON, JSON_PRETTY_PRINT));
    }
    
    if (isset($_GET["mode"]))
    {
        $MapAPI = "AIzaSyClGpcvf2I4kf8H7dmk1VA7EKv2INPjqTg";
        $mode = $_GET["mode"];
        $id = $_GET["id"];
        $origin = urlencode($_GET["origin"]);
        $directionURL = "https://maps.googleapis.com/maps/api/directions/json?mode=".$mode."&destination=place_id:".$id."&origin=".$origin."&key=".$MapAPI;
        $directionJSON = get_object_vars(json_decode(file_get_contents($directionURL)));
        echo(json_encode($directionJSON,JSON_PRETTY_PRINT));
    }
    
    if (isset($_GET["address"]))
    {
        $MapAPI = "AIzaSyClGpcvf2I4kf8H7dmk1VA7EKv2INPjqTg";
        $addy = urlencode($_GET["address"]);
        $geocodeURL = "https://maps.googleapis.com/maps/api/geocode/json?address=".$addy."&key=".$MapAPI;
        $geocodeJSON = get_object_vars(json_decode(file_get_contents($geocodeURL)));
        echo(json_encode($geocodeJSON,JSON_PRETTY_PRINT));
    }

    if(isset($_GET["country"]))
    {
        $yelpAPI = "aViMRsRLNDlsYQ7GntTkhrFpliIxk6S-IuZ-fT4_a4iF4xy5QQSYAENERCJTAH9LYve56BcG203IquAf26J_gog-c7I-j20P8fE26k_EzGgRN2Ft8363ITyzbubeWnYx";
        $yelpURL = "https://api.yelp.com/v3/businesses/matches?";
        if (isset($_GET["name"]))
        {
            $name = $_GET["name"];
            $yelpURL .= "name=".urlencode($name);
        }
        if (isset($_GET["addy"]))
        {
            $address = $_GET["addy"];
            $yelpURL .= "&address1=".urlencode($address);
        }
        if (isset($_GET["city"]))
        {
            $city = $_GET["city"];
            $yelpURL .= "&city=".urlencode($city);
        }
        if (isset($_GET["state"]))
        {
            $state = $_GET["state"];
            $yelpURL .= "&state=".urlencode($state);
        }
        if (isset($_GET["country"]))
        {
            $country = $_GET["country"];
            $yelpURL .= "&country=".urlencode($country);
        }

        $options = array(
            'http' => array(
            'header' => 'Authorization: Bearer '.$yelpAPI,
            'method' => 'GET'
            )
        );
        $context = stream_context_create($options);
        $result = get_object_vars(json_decode(file_get_contents($yelpURL,false,$context)));
        $business = $result["businesses"][0];
        
        if (array_key_exists ('id',$business))
        {
            $id = $business->id;
            $idURL = "https://api.yelp.com/v3/businesses/".$id."/reviews";
            $reviews = get_object_vars(json_decode(file_get_contents($idURL,false,$context)));
            echo(json_encode($reviews,JSON_PRETTY_PRINT));
        }
        else
        {
            echo("No ID");
        }
    }
?>
