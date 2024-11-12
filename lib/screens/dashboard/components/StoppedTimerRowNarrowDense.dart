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
import 'package:intl/intl.dart' as intl;
import 'package:timecop/blocs/projects/bloc.dart';
import 'package:timecop/models/timer_entry.dart';
import 'package:timecop/screens/dashboard/components/ProjectTag.dart';
import 'package:timecop/screens/dashboard/components/TimerDenseTrailing.dart';
import 'package:timecop/screens/timer/TimerEditor.dart';
import 'package:timecop/themes.dart';
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

class StoppedTimerRowNarrowDense extends StatelessWidget {
  final TimerEntry timer;
  final Function(BuildContext) resumeTimer;
  final Function(BuildContext) deleteTimer;
  const StoppedTimerRowNarrowDense(
      {Key? key,
      required this.timer,
      required this.resumeTimer,
      required this.deleteTimer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(timer.endTime != null);
    final directionality = Directionality.of(context);
    final tilePadding = Theme.of(context)
        .expansionTileTheme
        .tilePadding
        ?.resolve(directionality);
    final project =
        BlocProvider.of<ProjectsBloc>(context).getProjectByID(timer.projectID);
    final timeSpanStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: ThemeUtil.getOnBackgroundLighter(context),
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final timeFormat = intl.DateFormat.jm();
    final duration = timer.endTime!.difference(timer.startTime);

    // Get dynamic icon based on the task description
    final icon = getIconForDescription(timer.description ?? "");

    return Slidable(
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.15,
        children: <Widget>[
          SlidableAction(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              icon: FontAwesomeIcons.trash,
              onPressed: deleteTimer)
        ],
      ),
      child: ListTile(
          minVerticalPadding: 0,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          key: Key("stoppedTimer-${timer.id}"),
          leading: Icon(icon,
              color: Theme.of(context).colorScheme.primary), // Dynamic icon
          title: Padding(
              padding: EdgeInsetsDirectional.only(
                  start: (directionality == TextDirection.ltr
                          ? tilePadding?.left
                          : tilePadding?.right) ??
                      16,
                  top: tilePadding?.top ?? 0,
                  bottom: tilePadding?.bottom ?? 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        TimerUtils.formatDescription(
                            context, timer.description),
                        style: TimerUtils.styleDescription(
                            context, timer.description)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ProjectTag(project: project),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Text(
                          "${timeFormat.format(timer.startTime)}-${timeFormat.format(timer.endTime!)}",
                          style: timeSpanStyle,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        )),
                        if (duration.inDays > 0)
                          Transform.translate(
                            offset: const Offset(2, -4),
                            child: Text(
                              "+${duration.inDays}",
                              textScaleFactor: 0.8,
                              style: timeSpanStyle,
                            ),
                          )
                      ],
                    )
                  ])),
          trailing: TimerDenseTrailing(
              durationString: timer.formatTime(), resumeTimer: resumeTimer),
          onTap: () =>
              Navigator.of(context).push(MaterialPageRoute<TimerEditor>(
                builder: (BuildContext context) => TimerEditor(
                  timer: timer,
                ),
                fullscreenDialog: true,
              ))),
    );
  }
}
