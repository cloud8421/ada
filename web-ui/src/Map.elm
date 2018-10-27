module Map exposing (Map, toGmapsUrl)

import Url.Builder as Builder


type alias Map =
    { apiKey : String
    , coords : ( Float, Float )
    , markerText : String
    , width : Int
    , height : Int
    }


toGmapsUrl : Map -> String
toGmapsUrl map =
    let
        ( lat, lng ) =
            map.coords

        coordsPair =
            String.fromFloat lat ++ "," ++ String.fromFloat lng

        size =
            String.fromInt map.width ++ "x" ++ String.fromInt map.height

        markers =
            "color:blue|label:" ++ map.markerText ++ "|" ++ coordsPair
    in
    Builder.crossOrigin
        "https://maps.googleapis.com"
        [ "maps", "api", "staticmap" ]
        [ Builder.string "center" coordsPair
        , Builder.int "zoom" 13
        , Builder.string "size" size
        , Builder.string "maptype" "roadmap"
        , Builder.string "markers" markers
        , Builder.string "key" map.apiKey
        ]
