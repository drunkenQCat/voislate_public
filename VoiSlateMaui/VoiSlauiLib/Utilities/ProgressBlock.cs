namespace VoiSlauiLib.Utilities;

public class ProgressBlock
{
    private static readonly Lazy<ProgressBlock> _instance =
        new Lazy<ProgressBlock>(() => new ProgressBlock());

    public static ProgressBlock Instance => _instance.Value;

    public event EventHandler<double> ProgressHandler;

    public void OnProgress(double progress)
    {
        ProgressHandler?.Invoke(this, progress);
    }
}
