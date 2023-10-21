namespace VoiSlauiLib;
using VoiSlauiLib.Models;
using VoiSlauiLib.Helper;
using VoiSlauiLib.Utilities;

// All the code in this file is included in all platforms.
public class LogWriter
{
    List<SlateLogItem> logItemList = new();

    SlateLogItem? selectedItem;

    string filterText;


    string initJsonPath = @"C:\TechnicalProjects\VoiSlateParser\data.json";
    string? recordPath;
    FileLoadingHelper fhelper = FileLoadingHelper.Instance;
    public FilterType filterTypes;

    void IniLoadItems(string jsonPath)
    {
        fhelper.GetLogs(jsonPath);
        logItemList = fhelper.LogList;
    }


    void AddItem(SlateLogItem newItem)
    {
        logItemList.Add(newItem);
    }



    public void LoadLogItem(string path) => IniLoadItems(path);
    public void LoadBwf(string path) => fhelper.GetBwf(path);

    public void LoadAle(string path) => fhelper.GetAle(path);

    public void SaveAle(string path)
    {
        if (fhelper.Ale == null) return;
        fhelper.WriteAleData(path);
    }

    public void SaveBwf()
    {
        _ = fhelper.WriteMetaData();
    }
}

public enum FilterType
{
    name,
    date,
}
