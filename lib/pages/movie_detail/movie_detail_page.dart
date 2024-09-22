import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/common/utils.dart';
import 'package:movie_app/models/movie_detail_model.dart';
import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/models/watch_provider_model.dart';
import 'package:movie_app/services/api_services.dart';
import 'package:movie_app/models/movie_video_model.dart'; // Add: Movie Video Model
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // Add: Youtube Dependencie

class MovieDetailPage extends StatefulWidget {
  final int movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  ApiServices apiServices = ApiServices();

  late Future<MovieDetailModel> movieDetail;
  late Future<Result> movieRecommendationModel;
  late Future<List<MovieVideo>> movieVideos; // Add: Future para vídeos do filme
  late YoutubePlayerController
      _youtubePlayerController; // Add: Controller do Youtube
  late Future<WatchProviderResult>
      watchProviders; // Add: Future para watch providers

  @override
  void initState() {
    fetchInitialData();
    super.initState();
  }

  fetchInitialData() {
    movieDetail = apiServices.getMovieDetail(widget.movieId);
    movieRecommendationModel =
        apiServices.getMovieRecommendations(widget.movieId);
    movieVideos = apiServices
        .getMovieVideo(widget.movieId)
        .then((result) => result.results); // Add: Get -> Movie vídeos
    watchProviders = apiServices
        .getWatchProviders(widget.movieId); // Add: Get -> Watch Providers
  }

  // Add: Dispose -> Para garantir que a memória utilizada pelo player seja liberada
  @override
  void dispose() {
    _youtubePlayerController.dispose();
    super.dispose();
  }

  // Add: Youtube Initializer
  void initializeYoutubePlayer(String videoId) {
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    print(widget.movieId);
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: movieDetail,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final movie = snapshot.data;

              String genresText =
                  movie!.genres.map((genre) => genre.name).join(', ');

              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Update -> Alinha à esquerda
                children: [
                  Stack(
                    children: [
                      Container(
                        height: size.height * 0.4,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage("$imageUrl${movie.posterPath}"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: SafeArea(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios,
                                    color: Colors.white),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 25, left: 10, right: 10), // Update -> Padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Update -> Alinha à esquerda
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                              movie.releaseDate.year.toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 30),
                            Text(
                              genresText,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Text(
                          movie.overview,
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Updates -> Título da seção
                  Padding(
                    padding: EdgeInsets.only(top: 25, left: 10, right: 10),
                    child: const Text(
                      "Disponível em",
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: FutureBuilder<WatchProviderResult>(
                      future: watchProviders,
                      builder: (context, providerSnapshot) {
                        if (providerSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (providerSnapshot.hasError) {
                          return const Text('Erro ao carregar provedores.');
                        } else if (providerSnapshot.hasData) {
                          final providers = providerSnapshot.data!.results;
                          final brProviders = providers['BR'] ?? [];
                          if (brProviders.isEmpty) {
                            return const Text(
                              'Não disponível em serviços de streaming no Brasil.',
                              textAlign: TextAlign.left,
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: brProviders.map<Widget>((provider) {
                              return Text(
                                'Provedor: ${provider.providerName}',
                                textAlign: TextAlign.left,
                              );
                            }).toList(),
                          );
                        }
                        return const Text(
                          'Nenhum provedor encontrado.',
                          textAlign: TextAlign.left,
                        );
                      },
                    ),
                  ),
                  // Updates -> Título da seção
                  Padding(
                    padding: EdgeInsets.only(top: 25, left: 10, right: 10),
                    child: const Text(
                      "Assista ao Trailer",
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: FutureBuilder<List<MovieVideo>>(
                      future: movieVideos,
                      builder: (context, videoSnapshot) {
                        if (videoSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (videoSnapshot.hasError) {
                          return const Text('Erro ao carregar vídeos.');
                        } else if (videoSnapshot.hasData) {
                          final videos = videoSnapshot.data!;
                          final trailer = videos.firstWhere(
                            (video) =>
                                video.type == 'Trailer' &&
                                video.site == 'YouTube',
                            orElse: () => null as MovieVideo,
                          );

                          if (trailer != null) {
                            initializeYoutubePlayer(trailer.key);

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: YoutubePlayer(
                                controller: _youtubePlayerController,
                                showVideoProgressIndicator: true,
                                progressIndicatorColor: Colors.amber,
                              ),
                            );
                          } else {
                            return const Text(
                              'Nenhum trailer disponível.',
                              textAlign: TextAlign.left,
                            );
                          }
                        } else {
                          return const Text(
                            'Nenhum vídeo encontrado.',
                            textAlign: TextAlign.left,
                          );
                        }
                      },
                    ),
                  ),
                  // Updates -> Título da seção
                  Padding(
                    padding: EdgeInsets.only(top: 25, left: 10, right: 10),
                    child: const Text(
                      "Filmes semelhantes",
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder(
                    future: movieRecommendationModel,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final movie = snapshot.data;

                        return movie!.movies.isEmpty
                            ? const SizedBox()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    scrollDirection: Axis.vertical,
                                    itemCount: movie.movies.take(3).length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 15,
                                      childAspectRatio: 1.5 / 2,
                                    ),
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MovieDetailPage(
                                                      movieId: movie
                                                          .movies[index].id),
                                            ),
                                          );
                                        },
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              "$imageUrl${movie.movies[index].posterPath}",
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                      }
                      return const Text("Something went wrong");
                    },
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
