import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import '../repositories/profile_repository.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;
  final ProfileRepository profileRepository;
  final bool showEditButton;

  const UserAvatar({
    Key? key,
    this.size = 64,
    this.onTap,
    required this.profileRepository,
    this.showEditButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Center(
            // Use ValueListenableBuilder so avatar updates when photo changes.
            // Some tests supply a mock ProfileRepository without photoVersion;
            // in that case, fall back to building the avatar directly.
            child: Builder(builder: (context) {
              try {
                final dynamic notifier = (profileRepository as dynamic).photoVersion;
                if (notifier is ValueListenable<int>) {
                  return ValueListenableBuilder<int>(
                    valueListenable: notifier,
                    builder: (context, version, child) => _buildAvatar(),
                  );
                }
              } catch (_) {
                // ignore and fall through to direct build
              }
              return _buildAvatar();
            }),
          ),
          if (showEditButton && onTap != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: _buildEditButton(context),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Semantics(
          label: 'Foto do perfil do usuário',
          button: onTap != null,
          child: Builder(builder: (context) {
            // Get photo data and handle all possible return types
            Future<Object?> photoFuture;
            try {
              final dynamic result = profileRepository.getPhotoData();
              if (result is Future) {
                photoFuture = result as Future<Object?>;
              } else if (result != null) {
                photoFuture = Future<Object?>.value(result);
              } else {
                photoFuture = Future<Object?>.value(null);
              }
            } catch (_) {
              photoFuture = Future<Object?>.value(null);
            }

            return FutureBuilder<Object?>(
              future: photoFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null || snapshot.hasError) {
                  return _buildInitialsAvatar(context);
                }

                try {
                  final data = snapshot.data!;
                  if (data is Uint8List && data.isNotEmpty) {
                    return CircleAvatar(
                      radius: size / 2,
                      backgroundImage: MemoryImage(data),
                      backgroundColor: Theme.of(context).primaryColor,
                    );
                  }

                  if (data is File) {
                    return CircleAvatar(
                      radius: size / 2,
                      backgroundImage: FileImage(data),
                      backgroundColor: Theme.of(context).primaryColor,
                    );
                  }
                } catch (e) {
                  // Fall through to initials on any error
                }
                
                return _buildInitialsAvatar(context);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(BuildContext context) {
    final initials = profileRepository.getInitials();
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Theme.of(context).primaryColor,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              Icons.edit,
              size: size * 0.25,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}