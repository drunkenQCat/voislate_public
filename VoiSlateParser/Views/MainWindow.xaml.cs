using System;
using System.Linq;
using System.Windows;
using System.Windows.Forms;
using VoiSlateParser.ViewModels;

namespace VoiSlateParser
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }
        public void GetJsonPath_OnClick(object sender, EventArgs e)
        {
            string path;
            
            var dialog = new Microsoft.Win32.OpenFileDialog()
            {
                Title = "请选择场记Json文件",
                Filter = "场记文件 (*.json)|*.json",
            };
            if (dialog.ShowDialog() == true)
            {
                path = dialog.FileName;
                (this.DataContext as MainWindowViewModel)?.LoadLogItem(path);
            }
        }
        public void GetRecordPath_OnClick(object sender, EventArgs e)
        {
            FolderBrowserDialog folderBrowserDialog = new FolderBrowserDialog();
            if (folderBrowserDialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                string path = folderBrowserDialog.SelectedPath;
                (this.DataContext as MainWindowViewModel)?.LoadBwf(path);
            }
        }
        public void GetAlePath_OnClick(object sender, EventArgs e)
        {
            var folderBrowserDialog = new Microsoft.Win32.OpenFileDialog()
            {
                Title = "请选择剪辑软件元数据文件",
                // make the filter can select two types of files: csv, ale
                Filter = "达芬奇csv (*.csv)|*.csv|Ale (*.ale)|*.ale",
            };
            if (folderBrowserDialog.ShowDialog() == true)
            {
                string path = folderBrowserDialog.FileName;
                (this.DataContext as MainWindowViewModel)?.LoadAle(path);
            }
        }
        // a save path select window
        public void GetSavePath_OnClick(object sender, EventArgs e)
        {
            FolderBrowserDialog folderBrowserDialog = new FolderBrowserDialog();
            if (folderBrowserDialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                string path = folderBrowserDialog.SelectedPath;
                (this.DataContext as MainWindowViewModel)?.SaveAle(path);
            }
        }


    }
}
