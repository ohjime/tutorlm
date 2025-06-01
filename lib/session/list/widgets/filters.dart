import 'package:app/core/core.dart';
import 'package:app/session/session.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:change_case/change_case.dart';

class SessionListFilters extends StatefulWidget {
  const SessionListFilters({super.key, required this.onChanged});

  final void Function(SessionListFilter) onChanged;

  @override
  State<SessionListFilters> createState() => _SessionListFiltersState();
}

class _SessionListFiltersState extends State<SessionListFilters> {
  SessionListFilter _currentFilter = SessionListFilter(
    selectedDate: null,
    statuses: {SessionStatus.scheduled}, // Initially select "scheduled"
    searchStrings: {},
  );
  final TextEditingController _searchController = TextEditingController();
  
  // Keep track of the picker's selected date separately
  late DateTime _pickerSelectedDate;

  @override
  void initState() {
    super.initState();
    
    // Initialize picker selected date to today
    _pickerSelectedDate = DateTime.now();
    
    _searchController.addListener(() {
      _updateFilter(
        searchStrings: _searchController.text.isNotEmpty
            ? {_searchController.text}
            : {},
      );
    });

    // Call onChanged with initial filter to ensure "scheduled" is selected from start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(_currentFilter);
    });
  }

  void _updateFilter({
    DateTime? selectedDate,
    Set<SessionStatus>? statuses,
    Set<String>? searchStrings,
  }) {
    // Normalize selectedDate to remove time components
    final normalizedDate = selectedDate != null 
        ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
        : null;
        
    final newFilter = SessionListFilter(
      selectedDate: normalizedDate ?? _currentFilter.selectedDate,
      statuses: statuses ?? _currentFilter.statuses,
      searchStrings: searchStrings ?? _currentFilter.searchStrings,
    );
    if (newFilter != _currentFilter) {
      setState(() {
        _currentFilter = newFilter;
      });
      widget.onChanged(_currentFilter);
      context.read<SessionListBloc>().add(
        SessionListFilterChanged(_currentFilter),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 146,
          child: EasyTheme(
            data: EasyTheme.of(context).copyWithState(
              timelineOptions: TimelineOptions(height: 80),
              unselectedDayTheme: DayThemeData(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerLow,
                border: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                topElementStyle: TextStyle(fontSize: 16),
                middleElementStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                bottomElementStyle: TextStyle(fontSize: 16),
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              selectedDayTheme: DayThemeData(
                backgroundColor: Colors.green.shade100,
                border: BorderSide(color: Colors.green.shade100, width: 4.0),
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                topElementStyle: TextStyle(color: Colors.black),
                bottomElementStyle: TextStyle(color: Colors.black),
                foregroundColor: Colors.black,
              ),
            ),
            child: EasyDateTimeLinePicker(
              headerOptions: HeaderOptions(
                headerBuilder: (context, date, onTap) {
                  return Container(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Text(
                      '${DateFormat('EEEE').format(date)}, ${DateFormat('MMMM').format(date)} ${date.day}, ${date.year}',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
              focusedDate: _pickerSelectedDate,
              firstDate: DateTime(2025, 5, 01),
              lastDate: DateTime(2025, 05, 31),
              onDateChange: (date) {
                setState(() {
                  _pickerSelectedDate = date;
                });
                _updateFilter(selectedDate: date);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by Title or Instructor',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Session status chips for all SessionStatus values
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: SessionStatus.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final status = SessionStatus.values[i];
              final selected = _currentFilter.statuses.contains(status);
              return ChoiceChip(
                label: Text(status.name.toCapitalCase()),
                selected: selected,
                onSelected: (isSelected) {
                  final newStatuses = <SessionStatus>{};
                  if (isSelected) {
                    // Single select: only this status
                    newStatuses.add(status);
                  }
                  // If not selected, newStatuses remains empty (deselect all)
                  _updateFilter(statuses: newStatuses);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
