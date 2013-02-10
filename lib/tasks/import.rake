namespace :import do
  desc "Create episode instances for all anime"
  task :create_episodes => :environment do |t|
    Anime.all.select {|x| x.episode_count && x.episode_count > 0 }.each do |a|
      a.episode_count.times do |i|
        e = Episode.create(
          anime_id: a.id,
          number: i+1
        )
      end
    end
  end

  desc "Import pseudo-JSON formatted anime metadata from MAL"
  task :anime_metadata, [:filename] => :environment do |t, args|
    File.open(args[:filename]).readlines.map {|x| JSON.load x }.each do |meta|
      a = Anime.find_or_create_by_title(meta["title"])
      a.title = meta["title"]
      a.alt_title = meta["aka"]
      a.mal_id = meta["mal_id"]
      a.status = meta["status"]
      a.synopsis = meta["synopsis"]
      a.age_rating = meta["rating"]
      begin
        a.cover_image = URI.parse meta["cover_image_url"] unless a.cover_image.exists?
      rescue
        puts "Could not import cover image: #{meta["cover_image_url"]}"
      end
      a.episode_count = meta["episode_count"]
      a.episode_length = meta["episode_length"]

      # Genres
      meta["genres"].each {|g| Genre.find_or_create_by_name(g).save }
      a.genres = meta["genres"].map {|g| Genre.find_by_name(g) }

      # Producers
      meta["producers"].each {|g| Producer.find_or_create_by_name(g).save }
      a.producers = meta["producers"].map {|g| Producer.find_by_name(g) }

      a.save
      puts "Finished importing #{a.title}."
    end
  end
end
