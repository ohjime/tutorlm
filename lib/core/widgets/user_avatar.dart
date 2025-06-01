import 'package:app/app/app.dart'; // For AppBloc, AuthCredential, Authenticated state
import 'package:app/core/core.dart'; // For UserRepository, User model
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_bloc/flutter_bloc.dart'; // For context.select and context.read
import 'package:random_avatar/random_avatar.dart'; // Your RandomAvatar widget

// Define proportionality factors for internal elements
const double _kIndicatorSizeFactor =
    0.6; // e.g., loading indicator will be 60% of the circle's diameter

class UserAvatar extends StatefulWidget {
  final VoidCallback onPressed;

  const UserAvatar({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  // Store the Future<User> in the state
  Future<User>? _userFuture;
  // Keep track of the last known user ID to prevent unnecessary re-fetches
  String? _currentUserId;

  @override
  Widget build(BuildContext context) {
    final Color surfaceContainerHighest = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;

    // --- CRUCIAL CHANGE STARTS HERE ---
    // 1. Get authentication credential from AppBloc within the build method
    final credential = context.select<AppBloc, AuthCredential>((bloc) {
      final state = bloc.state;
      if (state is Authenticated) {
        return state.credential;
      } else {
        return AuthCredential.empty;
      }
    });

    // 2. Conditionally update the Future<User>
    // This logic ensures _userFuture is only re-assigned a new Future object
    // if the user ID has actually changed, or if it's the very first build.
    if (_userFuture == null || credential.id != _currentUserId) {
      _currentUserId = credential.id; // Update the stored ID
      final userRepository = context
          .read<UserRepository>(); // Access UserRepository within build method
      _userFuture = userRepository.getUser(
        credential.id,
      ); // Create the new Future
    }
    // --- CRUCIAL CHANGE ENDS HERE ---

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget
            .onPressed(); // Use widget.onPressed to access the parameter from the State
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double dynamicRadius = constraints.maxHeight / 2;
          final double dynamicChildSize =
              constraints.maxHeight * _kIndicatorSizeFactor;

          return FutureBuilder<User>(
            // 3. Use the stored and conditionally updated _userFuture
            future: _userFuture,
            initialData: User.empty,
            builder: (context, snapshot) {
              final imageUrl = snapshot.data?.imageUrl;
              final hasImage = imageUrl != null && imageUrl.isNotEmpty;
              final String userName = snapshot.data?.name ?? 'guest';

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircleAvatar(
                  radius: dynamicRadius,
                  backgroundColor: surfaceContainerHighest,
                  child: SizedBox(
                    width: dynamicChildSize,
                    height: dynamicChildSize,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              if (snapshot.hasError || snapshot.data == User.empty) {
                return CircleAvatar(
                  radius: dynamicRadius,
                  backgroundColor: surfaceContainerHighest,
                  child: Icon(Icons.error, size: dynamicChildSize),
                );
              }

              if (hasImage) {
                return CachedNetworkImage(
                  imageUrl: imageUrl,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: dynamicRadius,
                    backgroundImage: imageProvider,
                    backgroundColor: surfaceContainerHighest,
                  ),
                  placeholder: (context, url) => CircleAvatar(
                    radius: dynamicRadius,
                    backgroundColor: surfaceContainerHighest,
                    child: SizedBox(
                      width: dynamicChildSize,
                      height: dynamicChildSize,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: dynamicRadius,
                    backgroundColor: surfaceContainerHighest,
                    child: Icon(Icons.error, size: dynamicChildSize),
                  ),
                );
              } else {
                return CircleAvatar(
                  radius: dynamicRadius,
                  backgroundColor: surfaceContainerHighest,
                  child: RandomAvatar(userName, height: constraints.maxHeight),
                );
              }
            },
          );
        },
      ),
    );
  }
}
