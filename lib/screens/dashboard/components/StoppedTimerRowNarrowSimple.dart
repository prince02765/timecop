// Copyright 2020 Kenton Hamaluik
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timecop/blocs/projects/bloc.dart';
import 'package:timecop/l10n.dart';
import 'package:timecop/models/timer_entry.dart';
import 'package:timecop/screens/timer/TimerEditor.dart';
import 'package:timecop/utils/timer_utils.dart';

// Map of keywords to icons
final Map<String, IconData> keywordIconMap = {
  "study": Icons.book,
  "work": Icons.work,
  "play": Icons.sports_esports,
  "exercise": Icons.fitness_center,
  "travel": Icons.airplanemode_active,
  "music": Icons.music_note,
  "shopping": Icons.shopping_cart,
  "meeting": Icons.meeting_room,
  "call": Icons.phone,
  "read": Icons.menu_book,
  "sleep": Icons.bedtime,
  "clean": Icons.cleaning_services,
  "cook": Icons.kitchen,
  "eat": Icons.restaurant,
  "drink": Icons.local_drink,
  "relax": Icons.spa,
  "write": Icons.edit,
  "draw": Icons.brush,
  "run": Icons.directions_run,
  "walk": Icons.directions_walk,
  "drive": Icons.directions_car,
  "bike": Icons.directions_bike,
  "hike": Icons.landscape,
  "code": Icons.code,
  "game": Icons.videogame_asset,
  "watch": Icons.tv,
  "film": Icons.movie,
  "photo": Icons.camera_alt,
  "gym": Icons.sports_gymnastics,
  "garden": Icons.grass,
  "swim": Icons.pool,
  "dance": Icons.music_video,
  "sing": Icons.mic,
  "paint": Icons.palette,
  "meditate": Icons.self_improvement,
  "yoga": Icons.self_improvement,
  "organize": Icons.folder,
  "design": Icons.design_services,
  "explore": Icons.explore,
  "email": Icons.email,
  "chat": Icons.chat,
  "party": Icons.celebration,
  "news": Icons.article,
  "journal": Icons.book,
  "learn": Icons.school,
  "research": Icons.search,
  "plan": Icons.event,
  "decorate": Icons.home,
};

// Helper function to get the appropriate icon based on the description text
IconData? getIconForDescription(String description) {
  List<String> words = description.toLowerCase().split(" ");
  for (String word in words) {
    if (keywordIconMap.containsKey(word)) {
      return keywordIconMap[word];
    }
  }
  return Icons.task; // Default icon if no keyword matches
}

class StoppedTimerRowNarrowSimple extends StatefulWidget {
  final TimerEntry timer;
  final Function(BuildContext) resumeTimer;
  final Function(BuildContext) deleteTimer;

  const StoppedTimerRowNarrowSimple(
      {Key? key,
      required this.timer,
      required this.resumeTimer,
      required this.deleteTimer})
      : super(key: key);

  @override
  State<StoppedTimerRowNarrowSimple> createState() =>
      _StoppedTimerRowNarrowSimpleState();
}

class _StoppedTimerRowNarrowSimpleState
    extends State<StoppedTimerRowNarrowSimple> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    assert(widget.timer.endTime != null);

    final theme = Theme.of(context);

    // Get dynamic icon based on the task description
    final icon = getIconForDescription(widget.timer.description ?? "");

    return MouseRegion(
        onEnter: (_) => setState(() {
              _hovering = true;
            }),
        onExit: (_) => setState(() {
              _hovering = false;
            }),
        child: Slidable(
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.15,
            children: <Widget>[
              SlidableAction(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  icon: FontAwesomeIcons.trash,
                  onPressed: widget.deleteTimer)
            ],
          ),
          endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.15,
              children: <Widget>[
                SlidableAction(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    icon: FontAwesomeIcons.play,
                    onPressed: (_) => widget.resumeTimer(context))
              ]),
          child: ListTile(
              key: Key("stoppedTimer-${widget.timer.id}"),
              leading:
                  Icon(icon, color: theme.colorScheme.primary), // Dynamic icon
              title: Text(
                  TimerUtils.formatDescription(
                      context, widget.timer.description),
                  style: TimerUtils.styleDescription(
                      context, widget.timer.description)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  widget.timer.formatTime(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
                if (_hovering) const SizedBox(width: 4),
                if (_hovering)
                  IconButton(
                      icon: const Icon(FontAwesomeIcons.circlePlay),
                      onPressed: () => widget.resumeTimer(context),
                      tooltip: L10N.of(context).tr.resumeTimer),
              ]),
              onTap: () =>
                  Navigator.of(context).push(MaterialPageRoute<TimerEditor>(
                    builder: (BuildContext context) => TimerEditor(
                      timer: widget.timer,
                    ),
                    fullscreenDialog: true,
                  ))),
        ));
  }
}
