# Work with events in .Net Core

```csharp
using System;
using System.Threading;

namespace Events
{
    public class Video
    {
        public string Titile { get; set; }
    }

    public class VideoEncodedEventArgs : EventArgs
    {
        public Video Video { get; set; }
    }

    public class VideoEncodingEventArgs : EventArgs
    {
        public Video Video { get; set; }
    }

    public class VideoEncoder
    {
        //Steps
        //1 - Define a delegate
        //2 - Deifne an envent based on that delegate
        //3 - Raise the event

        /* Old
        public delegate void VideoEncodedEventHandler(object source, VideoEventArgs args);

        public event VideoEncodedEventHandler VideoEncoded;
        */

        //New
        public event EventHandler<VideoEncodedEventArgs> VideoEncoded;
        public event EventHandler<VideoEncodingEventArgs> VideoEncoding;


        public void Encode(Video video)
        {
            if (video is null)
            {
                return;
            }

            Console.WriteLine("Encoding Video...");
            const int TimeoutInMilliseconds = 3000;
            Thread.Sleep(TimeoutInMilliseconds);

            OnVideoEncoding(video);
            OnVideoEncoded(video);
        }

        protected virtual void OnVideoEncoding(Video video)
        {
            if (VideoEncoding is null)
            {
                return;
            }

            var videoEventArgs = new VideoEncodingEventArgs { Video = video };
            VideoEncoding(this, videoEventArgs);
        }

        protected virtual void OnVideoEncoded(Video video)
        {
            if (VideoEncoding is null)
            {
                return;
            }

            var videoEventArgs = new VideoEncodedEventArgs { Video = video };
            VideoEncoded(this, videoEventArgs);
        }
    }

    class Program
    {
        static void Main()
        {
            var video = new Video { Titile = "Video 1" };
            var videoEncoder = new VideoEncoder();
            var mailService = new MailService();
            var messageService = new MessageService();

            videoEncoder.VideoEncoding += mailService.OnVideoEncoding;
            videoEncoder.VideoEncoding += messageService.OnVideoEncoding;

            videoEncoder.VideoEncoded += mailService.OnVideoEncoded;
            videoEncoder.VideoEncoded += messageService.OnVideoEncoded;

            videoEncoder.Encode(video);
        }
    }

    public class MailService
    {
        public void OnVideoEncoding(object source, VideoEncodingEventArgs args)
        {
            Console.WriteLine($"MailService: Sending email - {args.Video.Titile} is encoding...");
        }

        public void OnVideoEncoded(object source, VideoEncodedEventArgs args)
        {
            Console.WriteLine($"MailService: Sending email - {args.Video.Titile} is encoded...");
        }
    }

    public class MessageService
    {
        public void OnVideoEncoding(object source, VideoEncodingEventArgs args)
        {
            Console.WriteLine($"MessageService: Sending message - {args.Video.Titile} is encoding...");
        }

        public void OnVideoEncoded(object source, VideoEncodedEventArgs args)
        {
            Console.WriteLine($"MessageService: Sending message - {args.Video.Titile} is encoded...");
        }
    }
}
```

## Credits

[C# Advanced Topics: Prepare for Technical Interviews](https://www.udemy.com/course/csharp-advanced/)

## Resources

[Microsoft Docs - Introduction to events](https://docs.microsoft.com/en-us/dotnet/csharp/events-overview)
