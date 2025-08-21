import 'package:flutter/material.dart';
import 'package:media_editor_app/view/crop/crop_list_item.dart';
import 'package:media_editor_app/view/crop/crop_region_box.dart';
import 'package:media_editor_app/view/crop/model/crop_region.dart';

class SettingPanel extends StatefulWidget {
  const SettingPanel({
    super.key,
    required this.cropRegions,
    required this.isSettingsPanelOpen,
    required this.onAdd,
    required this.onSelected,

    this.onInSettingsPanelChanged,
    this.selectedRegionId,
    this.onRemove,
    this.onUpdate,
  });
  final List<CropRegion> cropRegions;
  final bool isSettingsPanelOpen;
  final ValueChanged<bool>? onInSettingsPanelChanged;
  final ValueChanged<int>? onSelected;
  final VoidCallback onAdd;
  final int? selectedRegionId;
  final ValueChanged<int>? onRemove;
  final CropRegionUpdateCallback? onUpdate;

  @override
  State<SettingPanel> createState() => _SettingPanelState();
}

class _SettingPanelState extends State<SettingPanel> {
  static double PANEL_WIDTH = 500;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: widget.isSettingsPanelOpen == false
          ? SizedBox(
              width: PANEL_WIDTH,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (widget.onInSettingsPanelChanged != null) {
                              widget.onInSettingsPanelChanged!(true);
                            }
                          },
                          icon: Icon(Icons.settings),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : Container(
              width: PANEL_WIDTH,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (widget.onInSettingsPanelChanged != null) {
                              widget.onInSettingsPanelChanged!(false);
                            }
                          },
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          widget.onAdd();
                        },
                        icon: Icon(Icons.add),
                        label: Text('ADD CROP REGION'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (widget.cropRegions.isNotEmpty) Text('CROP REGIONS'),
                    SizedBox(height: 5),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.cropRegions.length,
                        itemBuilder: (context, index) {
                          final region = widget.cropRegions[index];
                          final isSelected =
                              widget.selectedRegionId == region.id;
                          return CropListItem(
                            key: ValueKey(region.id),
                            cropRegion: region,
                            isSelected: isSelected,
                            onUpdate: widget.onUpdate,
                            onSelected: widget.onSelected,
                            onRemove: widget.onRemove,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
