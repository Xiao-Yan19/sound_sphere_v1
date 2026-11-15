import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sound_sphere_v1/app/theme.dart';

import '../application/liked_songs_provider.dart';
import '../application/playlists_provider.dart';
import '../data/models/music_playlist.dart';

import '../../player/application/audio_handler_provider.dart';
import '../../player/presentation/player_screen.dart';

import 'liked_songs_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key, required this.onGoHome});

  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedAsync = ref.watch(likedSongsProvider);
    final playlistsAsync = ref.watch(playlistsProvider);
    final handler = ref.read(audioHandlerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              IconButton(
                tooltip: 'Go to Home',
                onPressed: onGoHome,
                icon: const Icon(
                  Icons.home_rounded,
                  color: AppColors.primary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Your Library',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            'Your music, all in one place.',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
          ),

          const SizedBox(height: 25),

          // LIKED SONGS
          likedAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (_, __) => const Text(
              'Could not load your saved music.',
              style: TextStyle(color: Colors.white70),
            ),
            data: (songs) => GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _LikedSongsRoute(onGoHome: onGoHome),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF287C72), Color(0xFF193C43)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Liked Songs',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${songs.length} songs',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // PLAYLIST HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Playlists',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showCreatePlaylistDialog(context, ref),
                icon: const Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 21,
                ),
                label: Text(
                  'Create',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // PLAYLIST LIST
          playlistsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (_, __) => const Text(
              'Could not load your playlists.',
              style: TextStyle(color: Colors.white70),
            ),
            data: (playlists) {
              if (playlists.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 27,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.queue_music_rounded,
                        size: 42,
                        color: Colors.white38,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No playlists yet',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Create a playlist and collect your favourite music.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: playlists.map((playlist) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _buildPlaylistCard(context, ref, playlist),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 28),

          // NOW PLAYING
          Text(
            'Now Playing',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          StreamBuilder<MediaItem?>(
            stream: handler.mediaItem,
            builder: (context, snapshot) {
              final item = snapshot.data;

              if (item == null) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Nothing is playing right now.',
                    style: TextStyle(color: Colors.white60),
                  ),
                );
              }

              return ListTile(
                contentPadding: const EdgeInsets.all(10),
                tileColor: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: item.artUri != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.network(
                          item.artUri.toString(),
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _musicIcon(),
                        ),
                      )
                    : _musicIcon(),
                title: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  item.artist ?? 'Unknown Artist',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60),
                ),
                trailing: const Icon(
                  Icons.graphic_eq_rounded,
                  color: AppColors.primary,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlayerScreen()),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistCard(
    BuildContext context,
    WidgetRef ref,
    MusicPlaylist playlist,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        leading: Container(
          width: 53,
          height: 53,
          decoration: BoxDecoration(
            color: const Color(0xFF244C47),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.queue_music_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        title: Text(
          playlist.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${playlist.tracks.length} songs',
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
        ),
        trailing: PopupMenuButton<String>(
          color: AppColors.cardBackground,
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
          onSelected: (value) async {
            if (value == 'rename') {
              await _showRenamePlaylistDialog(context, ref, playlist);
            } else if (value == 'delete') {
              await _confirmDeletePlaylist(context, ref, playlist);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'rename',
              child: Text('Rename', style: TextStyle(color: Colors.white)),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlaylistDetailScreen(playlistId: playlist.id),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCreatePlaylistDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _PlaylistNameDialog(
        title: 'Create Playlist',
        hint: 'Enter playlist name',
        actionLabel: 'Create',
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      await ref.read(playlistsProvider.notifier).createPlaylist(name);
    }
  }

  Future<void> _showRenamePlaylistDialog(
    BuildContext context,
    WidgetRef ref,
    MusicPlaylist playlist,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _PlaylistNameDialog(
        title: 'Rename Playlist',
        hint: 'Enter new playlist name',
        actionLabel: 'Save',
        initialName: playlist.name,
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      await ref
          .read(playlistsProvider.notifier)
          .renamePlaylist(playlist.id, name);
    }
  }

  Future<void> _confirmDeletePlaylist(
    BuildContext context,
    WidgetRef ref,
    MusicPlaylist playlist,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Delete Playlist?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "${playlist.name}"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ref.read(playlistsProvider.notifier).deletePlaylist(playlist.id);
    }
  }

  Widget _musicIcon() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(Icons.music_note_rounded, color: AppColors.primary),
    );
  }
}

// PLAYLIST DETAILS SCREEN
class PlaylistDetailScreen extends ConsumerWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);
    final handler = ref.read(audioHandlerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Playlist'),
      ),
      body: playlistsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => const Center(
          child: Text(
            'Could not load playlist.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        data: (playlists) {
          final matches = playlists.where(
            (playlist) => playlist.id == playlistId,
          );

          if (matches.isEmpty) {
            return const Center(
              child: Text(
                'Playlist not found.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final playlist = matches.first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                child: Row(
                  children: [
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: const Color(0xFF244C47),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.queue_music_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.name,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${playlist.tracks.length} songs',
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: playlist.tracks.isEmpty
                        ? null
                        : () async {
                            final playableTracks = playlist.tracks
                                .where(
                                  (track) =>
                                      track.audioUrl != null &&
                                      track.audioUrl!.isNotEmpty,
                                )
                                .toList();

                            if (playableTracks.isEmpty) return;

                            final items = playableTracks.map((track) {
                              return MediaItem(
                                id: track.audioUrl!,
                                title: track.name,
                                artist: track.artistName,
                                album: track.albumName ?? 'SoundSphere',
                                artUri:
                                    track.imageUrl != null &&
                                        track.imageUrl!.isNotEmpty
                                    ? Uri.tryParse(track.imageUrl!)
                                    : null,
                                extras: {'trackId': track.id},
                              );
                            }).toList();

                            await handler.playQueue(items: items);

                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PlayerScreen(),
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Play Playlist'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: playlist.tracks.isEmpty
                    ? const Center(
                        child: Text(
                          'This playlist is empty.\nAdd songs to get started.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, height: 1.6),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                        itemCount: playlist.tracks.length,
                        itemBuilder: (context, index) {
                          final track = playlist.tracks[index];

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 3,
                            ),
                            leading: track.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      track.imageUrl!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _detailMusicIcon(),
                                    ),
                                  )
                                : _detailMusicIcon(),
                            title: Text(
                              track.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              track.artistName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white60),
                            ),
                            trailing: IconButton(
                              tooltip: 'Remove from playlist',
                              onPressed: () {
                                ref
                                    .read(playlistsProvider.notifier)
                                    .removeTrack(playlist.id, track.id);
                              },
                              icon: const Icon(
                                Icons.remove_circle_outline_rounded,
                                color: Colors.white54,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _detailMusicIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.music_note_rounded, color: AppColors.primary),
    );
  }
}

// OPENS LIKED SONGS FROM LIBRARY
class _LikedSongsRoute extends StatelessWidget {
  const _LikedSongsRoute({required this.onGoHome});

  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LikedSongsScreen(
          onGoHome: () {
            Navigator.of(context).pop();
            onGoHome();
          },
        ),
      ),
    );
  }
}

class _PlaylistNameDialog extends StatefulWidget {
  const _PlaylistNameDialog({
    required this.title,
    required this.hint,
    required this.actionLabel,
    this.initialName = '',
  });

  final String title;
  final String hint;
  final String actionLabel;
  final String initialName;

  @override
  State<_PlaylistNameDialog> createState() => _PlaylistNameDialogState();
}

class _PlaylistNameDialogState extends State<_PlaylistNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.white38),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.of(context).pop(value.trim());
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _controller.text.trim();

            if (name.isNotEmpty) {
              Navigator.of(context).pop(name);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
          ),
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }
}
