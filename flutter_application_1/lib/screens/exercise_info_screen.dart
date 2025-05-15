import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../common/color_extension.dart';

class ExerciseInfoScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ExerciseInfoScreen({Key? key, required this.exercise}) : super(key: key);

  @override
  State<ExerciseInfoScreen> createState() => _ExerciseInfoScreenState();
}

class _ExerciseInfoScreenState extends State<ExerciseInfoScreen> {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.exercise['video_url'] != null) {
      _controller = VideoPlayerController.network(widget.exercise['video_url'])
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
          }
        }).catchError((error) {
          print('Error initializing video: ${widget.exercise['video_url']} - $error');
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0A0A),
            elevation: 0,
            expandedHeight: 220.0,
            floating: true,
            snap: true,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFFF5F5F5),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            title: Text(
              widget.exercise['nombre'] ?? 'Ejercicio sin nombre',
              style: GoogleFonts.poppins(
                color: const Color(0xFFF5F5F5),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'exercise_thumbnail_${widget.exercise['ejercicio_id']}',
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1976D2),
                            Color(0xFF42A5F5),
                          ],
                        ),
                      ),
                      child: Opacity(
                        opacity: 0.15,
                        child: widget.exercise['img_url'] != null
                            ? CachedNetworkImage(
                                imageUrl: widget.exercise['img_url'],
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.fitness_center,
                                  size: 120,
                                  color: Color(0xFFF5F5F5),
                                ),
                              )
                            : const Icon(
                                Icons.fitness_center,
                                size: 120,
                                color: Color(0xFFF5F5F5),
                              ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Section
                  if (widget.exercise['video_url'] != null && _controller != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Técnica',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFF5F5F5),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: _isVideoInitialized
                                    ? VideoPlayer(_controller!)
                                    : const Center(child: CircularProgressIndicator()),
                              ),
                              if (_isVideoInitialized)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                          color: const Color(0xFFF5F5F5),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (_controller!.value.isPlaying) {
                                              _controller!.pause();
                                            } else {
                                              _controller!.play();
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF252525),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Video no disponible',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFF5F5F5),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Description
                  Text(
                    'Descripción',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFF5F5F5),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.exercise['descripcion']?.toString() ?? 'Sin descripción',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFB0BEC5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Muscle Group
                  Text(
                    'Grupo Muscular',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFF5F5F5),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.exercise['grupo_muscular']?.toString() ?? 'Sin grupo muscular',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFB0BEC5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Equipment
                  Text(
                    'Equipamiento',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFF5F5F5),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.exercise['equipamiento']?.toString() ?? 'Sin equipamiento',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFB0BEC5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Instructions
                  Text(
                    'Instrucciones',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFF5F5F5),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.exercise['instrucciones']?.toString() ?? 'Sin instrucciones',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFB0BEC5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Category
                  Text(
                    'Categoría',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFF5F5F5),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.exercise['categoria']?.toString() ?? 'Sin categoría',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFB0BEC5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
        ],
      ),
    );
  }
}