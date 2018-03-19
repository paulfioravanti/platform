module Main exposing (..)

import Html exposing (Html, button, div, h1, li, p, strong, text, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode


-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { gamesList : List Game
    , playersList : List Player
    , errors : String
    }


type alias Game =
    { description : String
    , featured : Bool
    , id : Int
    , thumbnail : String
    , title : String
    }


type alias Player =
    { displayName : Maybe String
    , id : Int
    , score : Int
    , username : String
    }


initialModel : Model
initialModel =
    { gamesList = []
    , playersList = []
    , errors = ""
    }


initialCommand : Cmd Msg
initialCommand =
    Cmd.batch
        [ fetchGamesList
        , fetchPlayersList
        ]


init : ( Model, Cmd Msg )
init =
    ( initialModel, initialCommand )



-- API


fetchGamesList : Cmd Msg
fetchGamesList =
    decodeGamesList
        |> Http.get "/api/games"
        |> Http.send FetchGamesList


decodeGamesList : Decode.Decoder (List Game)
decodeGamesList =
    decodeGame
        |> Decode.list
        |> Decode.at [ "data" ]


decodeGame : Decode.Decoder Game
decodeGame =
    Decode.map5
        Game
        (Decode.field "description" Decode.string)
        (Decode.field "featured" Decode.bool)
        (Decode.field "id" Decode.int)
        (Decode.field "thumbnail" Decode.string)
        (Decode.field "title" Decode.string)


fetchPlayersList : Cmd Msg
fetchPlayersList =
    decodePlayersList
        |> Http.get "/api/players"
        |> Http.send FetchPlayersList


decodePlayersList : Decode.Decoder (List Player)
decodePlayersList =
    decodePlayer
        |> Decode.list
        |> Decode.at [ "data" ]


decodePlayer : Decode.Decoder Player
decodePlayer =
    Decode.map4
        Player
        (Decode.maybe (Decode.field "display_name" Decode.string))
        (Decode.field "id" Decode.int)
        (Decode.field "score" Decode.int)
        (Decode.field "username" Decode.string)



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ gamesIndex model
        , playersIndex model
        ]


gamesIndex : Model -> Html msg
gamesIndex model =
    if List.isEmpty model.gamesList then
        div [] []
    else
        div [ class "games-index" ]
            [ h1 [ class "games-section" ] [ text "Games" ]
            , gamesList model.gamesList
            ]


gamesList : List Game -> Html msg
gamesList games =
    ul [ class "games-list" ]
        (List.map gamesListItem games)


gamesListItem : Game -> Html msg
gamesListItem game =
    li [ class "game-item" ]
        [ strong []
            [ text game.title ]
        , p []
            [ text game.description ]
        ]


playersIndex : Model -> Html msg
playersIndex model =
    let
        playersSortedByScore =
            model.playersList
                |> List.sortBy .score
                |> List.reverse
    in
        if List.isEmpty model.playersList then
            div [] []
        else
            div [ class "players-index" ]
                [ h1 [ class "players-section" ] [ text "Players" ]
                , playersList playersSortedByScore
                ]


playersList : List Player -> Html msg
playersList players =
    ul [ class "players-list" ]
        (List.map playersListItem players)


playersListItem : Player -> Html msg
playersListItem player =
    let
        displayName =
            if player.displayName == Nothing then
                player.username
            else
                Maybe.withDefault "" player.displayName
    in
        li [ class "player-item" ]
            [ strong []
                [ text displayName ]
            , p []
                [ text (toString player.score) ]
            ]


type Msg
    = FetchGamesList (Result Http.Error (List Game))
    | FetchPlayersList (Result Http.Error (List Player))



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchGamesList result ->
            case result of
                Ok games ->
                    ( { model | gamesList = games }, Cmd.none )

                Err message ->
                    ( { model | errors = toString message }, Cmd.none )

        FetchPlayersList result ->
            case result of
                Ok players ->
                    ( { model | playersList = players }, Cmd.none )

                Err message ->
                    ( { model | errors = toString message }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
