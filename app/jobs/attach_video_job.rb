require "open3"
require "fileutils"

# Loom → MP4/GIF → R2 pipeline. Runs on the GoodJob worker. ActiveJob is queue-
# agnostic so the only change vs Solid Queue is the adapter (already wired in
# Rails config for lumelogics-server).
class AttachVideoJob < ApplicationJob
  queue_as :default

  retry_on StandardError, attempts: 3, wait: ->(executions) { executions * 5 }

  def perform(video_id)
    video = Video.find(video_id)
    return if video.status == "ready"

    slug     = video.slug
    mp4_path = File.join(Dir.tmpdir, "#{slug}.mp4")
    gif_path = File.join(Dir.tmpdir, "#{slug}.gif")

    download_mp4!(video, mp4_path)
    record_duration!(video, mp4_path)
    upload_mp4!(video, mp4_path, slug)
    generate_gif!(video, mp4_path, gif_path)
    upload_gif!(video, gif_path, slug)

    video.update!(
      player_url:    "#{ENV.fetch('PLAYER_BASE_URL')}/#{slug}",
      status:        "ready",
      error_message: nil,
    )
    Activity.log!(video.prospect, "video_ready", { video_id: video.id, slug: slug })
  rescue StandardError => e
    if (video = Video.find_by(id: video_id))
      video.update(status: "failed", error_message: "#{e.class}: #{e.message}")
      Activity.log!(video.prospect, "video_failed", { video_id: video.id, error: e.message })
    end
    raise
  ensure
    FileUtils.rm_f(mp4_path) if defined?(mp4_path) && mp4_path
    FileUtils.rm_f(gif_path) if defined?(gif_path) && gif_path
  end

  private

  def download_mp4!(video, mp4_path)
    video.update!(status: "downloading")
    FileUtils.rm_f(mp4_path)
    cmd = [
      ENV.fetch("YT_DLP_PATH"),
      video.loom_url,
      "-o", mp4_path,
      "--merge-output-format", "mp4",
      "--no-progress",
      "--quiet",
    ]
    run!(cmd, "yt-dlp")
    unless File.exist?(mp4_path) && File.size?(mp4_path).to_i > 0
      raise "yt-dlp completed but #{mp4_path} is missing or empty"
    end
  end

  def record_duration!(video, mp4_path)
    cmd = [
      ENV.fetch("FFPROBE_PATH"),
      "-v", "error",
      "-show_entries", "format=duration",
      "-of", "default=noprint_wrappers=1:nokey=1",
      mp4_path,
    ]
    stdout, _stderr = run!(cmd, "ffprobe")
    video.update!(duration_seconds: stdout.strip.to_f.round)
  end

  def upload_mp4!(video, mp4_path, slug)
    video.update!(status: "uploading_mp4")
    key = "videos/#{slug}.mp4"
    url = Outreel::R2Client.upload_file(mp4_path, key, "video/mp4")
    video.update!(r2_mp4_key: key, mp4_url: url)
  end

  def generate_gif!(video, mp4_path, gif_path)
    video.update!(status: "generating_gif")
    FileUtils.rm_f(gif_path)
    filter =
      "fps=12,scale=360:-1:flags=lanczos,split[s0][s1];" \
      "[s0]palettegen[p];[s1][p]paletteuse"
    cmd = [
      ENV.fetch("FFMPEG_PATH"),
      "-y",
      "-i", mp4_path,
      "-ss", "1",
      "-t",  "4",
      "-vf", filter,
      "-loop", "0",
      gif_path,
    ]
    run!(cmd, "ffmpeg")
    unless File.exist?(gif_path) && File.size?(gif_path).to_i > 0
      raise "ffmpeg completed but #{gif_path} is missing or empty"
    end
  end

  def upload_gif!(video, gif_path, slug)
    video.update!(status: "uploading_gif")
    key = "videos/#{slug}.gif"
    url = Outreel::R2Client.upload_file(gif_path, key, "image/gif")
    video.update!(r2_gif_key: key, gif_url: url)
  end

  def run!(cmd, label)
    stdout, stderr, status = Open3.capture3(*cmd)
    unless status.success?
      raise "#{label} failed (exit #{status.exitstatus}): #{stderr.to_s.strip.lines.last(5).join}"
    end
    [stdout, stderr]
  end
end
