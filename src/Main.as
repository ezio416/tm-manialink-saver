// c 2024-02-02
// m 2024-02-03

const string folderEditor     = "editor_CSmEditorPluginMapType/";
const string folderMenu       = "menu_CGameManiaAppTitle/";
const string folderPlayground = "playground_CGameManiaAppPlayground/";
bool         saving           = false;
const float  scale            = UI::GetScale();
const string title            = "\\$FF2" + Icons::Link + "\\$G ManiaLink Saver";

[Setting category="General" name="Show window"]
bool S_Show = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = true;

void Main() {
    IO::CreateFolder(IO::FromStorageFolder(folderEditor));
    IO::CreateFolder(IO::FromStorageFolder(folderMenu));
    IO::CreateFolder(IO::FromStorageFolder(folderPlayground));

    IO::File file(IO::FromStorageFolder("recommended.txt"), IO::FileMode::Write);
    file.Write("In order to more easily read the ManiaScript code in these files, I recommend using the VSCode extension 'maniascript-support'");
    file.Close();
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Show))
        S_Show = !S_Show;
}

void Render() {
    if (
        !S_Show ||
        (S_HideWithGame && !UI::IsGameUIVisible()) ||
        (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    if (Network is null)
        return;

    UI::Begin(title, S_Show, UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse);
        vec2 buttonSize = vec2(scale * 250.0f, scale * 30.0f);

        if (UI::Button(Icons::ExternalLink + " Open folder", buttonSize))
            OpenExplorerPath(IO::FromStorageFolder(""));

        UI::BeginDisabled(saving);
            if (UI::Button(Icons::FloppyO + " Save ManiaLinks from main menu", buttonSize))
                startnew(SaveMenu);

            UI::BeginDisabled(Network.ClientManiaAppPlayground is null);
                if (UI::Button(Icons::FloppyO + " Save ManiaLinks from playground", buttonSize))
                    startnew(SavePlayground);
            UI::EndDisabled();

            UI::BeginDisabled(App.Editor is null);
                if (UI::Button(Icons::FloppyO + " Save ManiaLinks from editor", buttonSize))
                    startnew(SaveEditor);
            UI::EndDisabled();
        UI::EndDisabled();
    UI::End();
}

void SaveMenu() {
    if (saving)
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CTrackManiaMenus@ Menus = cast<CTrackManiaMenus@>(App.MenuManager);
    if (Menus is null)
        return;

    CGameManiaAppTitle@ ManiaApp = Menus.MenuCustom_CurrentManiaApp;
    if (ManiaApp is null || ManiaApp.UILayers.Length == 0)
        return;

    saving = true;

    for (uint i = 0; i < ManiaApp.UILayers.Length; i++) {
        CGameUILayer@ Layer = ManiaApp.UILayers[i];
        if (Layer is null)
            continue;

        string page = string(Layer.ManialinkPage);

        int start = page.IndexOf("<");
        int end = page.IndexOf(">");

        if (start > -1 && end > -1) {
            string header = page.SubStr(start, end + 1 - start).Replace(" version=\"3\"", "");
            string name = GoodFileName(header.SubStr(17, header.Length - 19));

            IO::File file(IO::FromStorageFolder(folderMenu + name + ".xml"), IO::FileMode::Write);
            file.Write(page);
            file.Close();

            yield();
        }
    }

    saving = false;
}

void SavePlayground() {
    if (saving)
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    if (Network is null)
        return;

    CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;
    if (CMAP is null || CMAP.UILayers.Length == 0)
        return;

    saving = true;

    for (uint i = 0; i < CMAP.UILayers.Length; i++) {
        CGameUILayer@ Layer = CMAP.UILayers[i];
        if (Layer is null)
            continue;

        string page = string(Layer.ManialinkPage);

        int start = page.IndexOf("<");
        int end = page.IndexOf(">");

        if (start > -1 && end > -1) {
            string header = page.SubStr(start, end + 1 - start).Replace(" version=\"3\"", "");
            string name = GoodFileName(header.SubStr(17, header.Length - 19));

            IO::File file(IO::FromStorageFolder(folderPlayground + name + ".xml"), IO::FileMode::Write);
            file.Write(page);
            file.Close();

            yield();
        }
    }

    saving = false;
}

void SaveEditor() {
    if (saving)
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree@>(App.Editor);
    if (Editor is null)
        return;

    CSmEditorPluginMapType@ Type = cast<CSmEditorPluginMapType@>(Editor.PluginMapType);
    if (Type is null || Type.UILayers.Length == 0)
        return;

    saving = true;

    for (uint i = 0; i < Type.UILayers.Length; i++) {
        CGameUILayer@ Layer = Type.UILayers[i];
        if (Layer is null)
            continue;

        string page = string(Layer.ManialinkPage);

        int start = page.IndexOf("<");
        int end = page.IndexOf(">");

        if (start > -1 && end > -1) {
            string header = page.SubStr(start, end + 1 - start).Replace(" version=\"3\"", "");
            string name = GoodFileName(header.SubStr(17, header.Length - 19));

            IO::File file(IO::FromStorageFolder(folderEditor + name + ".xml"), IO::FileMode::Write);
            file.Write(page);
            file.Close();

            yield();
        }
    }

    saving = false;
}

string GoodFileName(const string &in name) {
    string result = name.Replace("/", "_");

    result = result.Replace("\\", "_");
    result = result.Replace(":", "_");
    result = result.Replace("*", "_");
    result = result.Replace("?", "_");
    result = result.Replace("\"", "_");
    result = result.Replace("<", "_");
    result = result.Replace(">", "_");
    result = result.Replace("|", "_");

    return result;
}