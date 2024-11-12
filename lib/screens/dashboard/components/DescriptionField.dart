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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecop/blocs/settings/settings_bloc.dart';
import 'package:timecop/blocs/timers/bloc.dart';
import 'package:timecop/blocs/projects/bloc.dart';
import 'package:timecop/l10n.dart';
import 'package:timecop/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class DescriptionField extends StatefulWidget {
  const DescriptionField({Key? key}) : super(key: key);

  @override
  State<DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<DescriptionField> {
  TextEditingController? _controller;
  FocusNode? _focus;
  IconData? taskIcon; // Icon that changes based on text input

  // Mapping of keywords to icons
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
    "relax": Icons.wb_sunny,
    "news": Icons.article,
    "journal": Icons.book,
    "learn": Icons.school,
    "research": Icons.search,
    "study": Icons.school,
    "plan": Icons.event,
    "decorate": Icons.home,
    "call": Icons.call,
  };

  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<DashboardBloc>(context);
    _controller = TextEditingController(text: bloc.state.newDescription);
    _focus = FocusNode();

    // Add listener to update icon based on the input text
    _controller!.addListener(() {
      setState(() {
        taskIcon = _getIconForKeywords(_controller!.text);
      });
    });
  }

  // Function to determine icon based on keywords
  IconData? _getIconForKeywords(String text) {
    // Convert text to lowercase and split by spaces
    List<String> words = text.toLowerCase().split(" ");

    // Find the first icon that matches a keyword in the map
    for (String word in words) {
      if (keywordIconMap.containsKey(word)) {
        return keywordIconMap[word];
      }
    }
    return null; // No icon if no keywords match
  }

  @override
  void dispose() {
    _controller!.dispose();
    _focus!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<DashboardBloc>(context);
    final timers = BlocProvider.of<TimersBloc>(context);
    final settings = BlocProvider.of<SettingsBloc>(context);

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (BuildContext context, DashboardState state) {
        if (state.timerWasStarted) {
          _controller!.clear();
          _focus!.unfocus();
          bloc.add(const ResetEvent());
        }

        Widget textFieldWidget = settings.state.autocompleteDescription
            ? TypeAheadField<String?>(
                direction: AxisDirection.up,
                textFieldConfiguration: TextFieldConfiguration(
                    focusNode: _focus,
                    controller: _controller,
                    autocorrect: true,
                    decoration: InputDecoration(
                        hintText: L10N.of(context).tr.whatAreYouDoing),
                    onChanged: (dynamic description) => bloc
                        .add(DescriptionChangedEvent(description as String)),
                    onSubmitted: (dynamic description) {
                      _focus!.unfocus();
                      bloc.add(DescriptionChangedEvent(description as String));
                      final timers = BlocProvider.of<TimersBloc>(context);
                      if (settings.state.oneTimerAtATime) {
                        timers.add(const StopAllTimers());
                      }
                      timers.add(CreateTimer(
                          description: bloc.state.newDescription,
                          project: bloc.state.newProject));
                      bloc.add(const TimerWasStartedEvent());
                    }),
                itemBuilder: (BuildContext context, String? desc) =>
                    ListTile(title: Text(desc!)),
                noItemsFoundBuilder: (context) => ListTile(
                    title: Text(L10N.of(context).tr.noItemsFound),
                    enabled: false),
                onSuggestionSelected: (String? description) {
                  _controller!.text = description!;
                  bloc.add(DescriptionChangedEvent(description));
                },
                suggestionsCallback: (pattern) async {
                  if (pattern.length < 2) return [];

                  final projectsBloc = BlocProvider.of<ProjectsBloc>(context);
                  final descriptions = timers.state.timers
                      .where((timer) => timer.description != null)
                      .where((timer) => !(projectsBloc
                              .getProjectByID(timer.projectID)
                              ?.archived ==
                          true))
                      .where((timer) =>
                          timer.description
                              ?.toLowerCase()
                              .contains(pattern.toLowerCase()) ??
                          false)
                      .map((timer) => timer.description)
                      .toSet()
                      .toList();
                  return descriptions;
                },
              )
            : TextField(
                key: const Key("descriptionField"),
                focusNode: _focus,
                controller: _controller,
                autocorrect: true,
                decoration: InputDecoration(
                  hintText: L10N.of(context).tr.whatAreYouDoing,
                ),
                onChanged: (String description) =>
                    bloc.add(DescriptionChangedEvent(description)),
                onSubmitted: (String description) {
                  _focus!.unfocus();
                  bloc.add(DescriptionChangedEvent(description));
                  final timers = BlocProvider.of<TimersBloc>(context);
                  if (settings.state.oneTimerAtATime) {
                    timers.add(const StopAllTimers());
                  }
                  timers.add(CreateTimer(
                      description: bloc.state.newDescription,
                      project: bloc.state.newProject));
                  bloc.add(const TimerWasStartedEvent());
                },
              );

        return Row(
          children: [
            if (taskIcon != null)
              Icon(
                taskIcon, // Display the icon based on task
                color: Colors.blue, // Customize icon color if needed
              ),
            Expanded(child: textFieldWidget),
          ],
        );
      },
    );
  }
}
