module Settings exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import WebData exposing (WebData(..))
import WebData.Http
import Types exposing (Language(..), Context, ContextUpdate(..), Translations)
import Decoders
import I18n


type alias Model =
    { selectedLanguage : Language
    }


type Msg
    = SelectLanguage Language
    | HandleTranslationsResponse (WebData Translations)


initModel : Model
initModel =
    { selectedLanguage = English
    }


update : Context -> Msg -> Model -> ( Model, Cmd Msg, ContextUpdate )
update context msg model =
    case msg of
        SelectLanguage lang ->
            ( { model | selectedLanguage = lang }
            , getTranslations lang
            , NoUpdate
            )

        HandleTranslationsResponse webData ->
            case webData of
                Success translations ->
                    ( model, Cmd.none, UpdateTranslations translations )

                _ ->
                    ( model, Cmd.none, NoUpdate )


getTranslations : Language -> Cmd Msg
getTranslations language =
    let
        url =
            case language of
                English ->
                    "/api/en.json"

                Finnish ->
                    "/api/fi.json"

                FinnishFormal ->
                    "/api/fi-formal.json"
    in
        WebData.Http.get url HandleTranslationsResponse Decoders.decodeTranslations


view : Context -> Model -> Html Msg
view context model =
    div []
        [ h2 [] [ text (I18n.get context.translations "language-selection-heading") ]
        , selectionButton model English "English"
        , selectionButton model Finnish "Suomi"
        , selectionButton model FinnishFormal "Suomi (virallinen)"
        ]


selectionButton : Model -> Language -> String -> Html Msg
selectionButton model language shownName =
    button
        [ disabled (model.selectedLanguage == language)
        , onClick (SelectLanguage language)
        ]
        [ text shownName ]
