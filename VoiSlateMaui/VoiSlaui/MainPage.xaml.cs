using VoiSlauiLib.Models;
using VoiSlauiLib.Helper;
using andEnv = Android.OS.Environment;
using VoiSlauiLib.Utilities;
using Android.Content;
using Microsoft.Maui.ApplicationModel;
using Android.App;

namespace VoiSlaui;
public partial class MainPage : ContentPage
{
    List<SlateLogItem> logItemList = new();
    FileLoadingHelper fhelper = FileLoadingHelper.Instance;
    SafService safService = new();


    public MainPage()
    {
        InitializeComponent();
        CopyRecordsBtn.IsEnabled = false;
        WriteRecordsBtn.IsEnabled = false;
    }

    private async void OnSlatePickerClicked(object sender, EventArgs e)
    {
#if ANDROID
        DotNetBot.Source = "dotnet_bot_read_slate.png";
        PickOptions options = new()
        {
            PickerTitle = "请选取场记json文件",
            FileTypes = new(
                new Dictionary<DevicePlatform, IEnumerable<string>>
                {
                    { DevicePlatform.Android, new[] { "application/json" } }, // MIME type
                }
                ),

        };
        var pickResult = await FilePicker.Default.PickAsync(options);

        if (pickResult is not null)
        {
            Console.WriteLine("Selected folder: " + pickResult.FullPath);
            fhelper.GetLogs(pickResult.FullPath);
            logItemList = fhelper.LogList;
            var logLength = logItemList.Count;
            if (logItemList is null || logLength <= 0) { 
                await displayErrorMessage(pickResult);
                return;
            }

            var lastThreeLogs = $"最后三条场记：\n" +
                $"{logItemList.Last().fileName}\t" +
                $"{logItemList.Last().scn}场{logItemList.Last().sht}镜{logItemList.Last().tk}次 \t {logItemList.Last().shtNote}\n" +
                $"{logItemList[logLength - 2].fileName}\t" +
                $"{logItemList[logLength - 2].scn}场{logItemList[logLength - 2].sht}镜{logItemList[logLength - 2].tk}次 \t {logItemList[logLength - 2].shtNote}\n" +
                $"{logItemList[logLength - 3].fileName}\t" +
                $"{logItemList[logLength - 3].scn}场{logItemList[logLength - 3].sht}镜{logItemList[logLength - 3].tk}次 \t {logItemList[logLength - 3].shtNote}\n";
            await DisplayAlert("场记读取成功", $"一共{logItemList.Count}条场记已加载\n {lastThreeLogs}", "确定");
        }
        else
        {
            await displayErrorMessage(pickResult);
        }
        CopyRecordsBtn.IsEnabled = true;

        async Task displayErrorMessage(FileResult pickResult)
        {
            await DisplayAlert("读取失败", $"错误信息: {pickResult.FileName}", "确定");
        }
        // Todo:Loading...
#endif
    }

    private void OnCopyClicked(object sender, EventArgs e)
    {
        DotNetBot.Source = "dotnet_bot_copy_wav.png";
        WriteRecordsBtn.IsEnabled = true;
        safService.ShowUriBrowser();
    }

    private async void OnWriteClicked(object sender, EventArgs e)
    {
        var desPath = andEnv.GetExternalStoragePublicDirectory(andEnv.DirectoryMovies);
        var flag = await DisplayAlert("已选择文件夹", $"即将向Movies/{SafService.FolderName}文件夹备份文件", "点击继续", "重新选择");
        if (!flag) { return; }
        await copyRecords(safService);
        await readBwfInfo();

        await writeMetadata();
        DotNetBot.Source = "dotnet_bot_ok.png";


        async Task copyRecords(SafService safService)
        {
            progressIndicator.Text = $"正在复制文件到Movies/{SafService.FolderName}文件夹";
            Task copyAllRecords = new TaskFactory().StartNew(
                () => safService.CopyAllFromExternalStorage(desPath.AbsolutePath)
                );
            Task progressBarTask = progressBar.ProgressTo(0.75, 100000, Easing.Linear);
            await Task.WhenAll(progressBarTask, copyAllRecords).ConfigureAwait(false);
            await progressBar.ProgressTo(0.85, 1, Easing.Linear).ConfigureAwait(false);
        }

        async Task readBwfInfo()
        {
            progressIndicator.Text = "正在读取录音文件元数据";
            var destinyPath = Path.Combine(desPath.AbsolutePath, SafService.FolderName);
            int matchedCount = fhelper.GetBwf(destinyPath);
            await progressBar.ProgressTo(1, 100, Easing.CubicIn);
            progressIndicator.Text = "复制完成";
            await DisplayAlert("录音已复制到Movies", $"{matchedCount}条录音已匹配，即将向{SafService.FolderName}文件夹写入元数据", "点击继续");
        }

        async Task writeMetadata()
        {
            // 写入元数据
            DotNetBot.Source = "dotnet_bot_write_metadata.png";
            SubscribeProgress();
            progressIndicator.Text = "正在对录音备份写入元数据";
            Task task = new TaskFactory().StartNew(() => fhelper.WriteMetaData());
            await task;
            progressIndicator.Text = "元数据已写入完成，请安全移除SD卡";
            await DisplayAlert("写入完成", "元数据已写入，请安全移除SD卡", "确定");

        }
    }

    private void SubscribeProgress()
    {
        ProgressBlock.Instance.ProgressHandler += (_, progressCount) =>
        {
            progressBar.ProgressTo(progressCount, 0, Easing.CubicIn);
        };
    }

}
