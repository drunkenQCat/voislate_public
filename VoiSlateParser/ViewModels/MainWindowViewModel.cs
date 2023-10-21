using System;
using System.Collections.Generic;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using VoiSlateParser.Models;
using VoiSlateParser.Helper;
using System.ComponentModel;
using System.Threading.Tasks;
using System.Windows.Data;
using HandyControl.Controls;
using VoiSlateParser.Utilities;
using VoiSlateParser.Views.Widgets;
using MessageBox = System.Windows.MessageBox;

namespace VoiSlateParser.ViewModels;

public partial class MainWindowViewModel : ObservableObject
{
        List<SlateLogItem> logItemList = new();
        AlePaser timelineAle;
        [ObservableProperty]
        ICollectionView collectionView;
        
        [ObservableProperty]
        SlateLogItem? selectedItem;

        [ObservableProperty] 
        string filterText = "";
        
        
        [ObservableProperty]
        string initJsonPath = @"test_data.json";

        [ObservableProperty] 
        bool isBwfImportingEnabled = false;
        
        [ObservableProperty] 
        bool isWritingEnabled = false;
        
        [ObservableProperty] 
        bool isAleImportingEnabled = false;
        
        [ObservableProperty] 
        bool isAleExportingEnabled = false;
        
        string? recordPath;
        FileLoadingHelper fhelper = FileLoadingHelper.Instance;
        public FilterType filterTypes;

        [RelayCommand]
        void IniLoadItems(string jsonPath)
        {
            try
            {
                fhelper.GetLogs(jsonPath);
                logItemList = fhelper.LogList;
                CollectionView = CollectionViewSource.GetDefaultView(logItemList);
                CollectionView.Filter = (item) =>
                {
                    if (string.IsNullOrEmpty(FilterText)) return true;
                    var im = item as SlateLogItem;
                    // find all the fields in the slateLogItem, and find if the filter is 
                    // contained in any of them.
                    return im.Contains(FilterText);
                };
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading JSON data: {ex.Message}");
            }
        }
        // [RelayCommand]
        

        [RelayCommand]
        void AddItem(SlateLogItem newItem)
        {
            logItemList.Add(newItem);
        }

        [RelayCommand]
        void DeleteItem()
        {
            if (SelectedItem != null)
            {
                logItemList.Remove(SelectedItem);
            }
        }

        [RelayCommand]
        public async void SaveBwf()
        {
            IsWritingEnabled = false;
            var d = Dialog.Show<WaitingDialog>();
            Task task = new TaskFactory().StartNew(() => fhelper.WriteMetaData());
            await task;
            d.Close();
            IsWritingEnabled = true;
        }
        partial void OnFilterTextChanged(string? oldValue, string newValue) => CollectionView.Refresh();

        public void LoadLogItem(string path)
        {
            Task.Run(() => IniLoadItems(path));
            IsBwfImportingEnabled = true;
        }

        public void LoadBwf(string path)
        {
            Task.Run(() => fhelper.GetBwf(path));
            IsAleImportingEnabled = true;
            IsWritingEnabled = true;
        }

        public void LoadAle(string path)
        {
            Task.Run(() => fhelper.GetAle(path));
            IsAleExportingEnabled = true;
        }

        public void SaveAle(string path)
        {
            if(fhelper.Ale == null) return;
            Task.Run(() => fhelper.WriteAleData(path));
            
        }

}

public enum FilterType
{
    name,
    date,
}