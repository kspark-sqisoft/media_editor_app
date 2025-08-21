import 'package:flutter/material.dart';
import 'package:media_editor_app/main.dart';
import 'package:media_editor_app/view/crop/crop_region_box.dart';
import 'package:media_editor_app/view/crop/model/crop_region.dart';

class CropListItem extends StatefulWidget {
  const CropListItem({
    super.key,
    required this.cropRegion,
    required this.isSelected,
    this.onSelected,
    this.onUpdate,
    this.onRemove,
  });
  final bool isSelected;
  final CropRegion cropRegion;
  final ValueChanged<int>? onSelected;
  final CropRegionUpdateCallback? onUpdate;
  final ValueChanged<int>? onRemove;

  @override
  State<CropListItem> createState() => _CropListItemState();
}

class _CropListItemState extends State<CropListItem> {
  late TextEditingController nameController;
  late TextEditingController xController;
  late TextEditingController yController;
  late TextEditingController wController;
  late TextEditingController hController;
  @override
  void initState() {
    nameController = TextEditingController(text: widget.cropRegion.name);
    xController = TextEditingController(
      text: widget.cropRegion.x.toInt().toString(),
    );
    yController = TextEditingController(
      text: widget.cropRegion.y.toInt().toString(),
    );
    wController = TextEditingController(
      text: widget.cropRegion.width.toInt().toString(),
    );
    hController = TextEditingController(
      text: widget.cropRegion.height.toInt().toString(),
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CropListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // cropRegion 이 바뀌면 controller 값도 갱신
    if (oldWidget.cropRegion != widget.cropRegion) {
      nameController.text = widget.cropRegion.name;
      xController.text = widget.cropRegion.x.toInt().toString();
      yController.text = widget.cropRegion.y.toInt().toString();
      wController.text = widget.cropRegion.width.toInt().toString();
      hController.text = widget.cropRegion.height.toInt().toString();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    xController.dispose();
    yController.dispose();
    wController.dispose();
    hController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onSelected != null) {
          widget.onSelected!(widget.cropRegion.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Colors.red.withValues(alpha: 0.3)
              : widget.cropRegion.color!.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //이름
                SizedBox(
                  width: 100,
                  height: 20,
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'NAME',
                      labelStyle: TextStyle(fontSize: 8),
                      contentPadding: const EdgeInsets.all(4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    style: TextStyle(fontSize: 10),
                    onSubmitted: (value) {
                      logger.d('onSubmitted');
                      if (widget.onUpdate != null) {
                        final updatedCropRegion = widget.cropRegion.copyWith(
                          name: value,
                        );
                        widget.onUpdate!(
                          widget.cropRegion.id,
                          updatedCropRegion,
                        );
                      }
                    },
                    onTap: () {
                      if (widget.onSelected != null) {
                        widget.onSelected!(widget.cropRegion.id);
                      }
                    },
                  ),
                ),

                //X
                SizedBox(
                  width: 50,
                  height: 20,
                  child: TextField(
                    controller: xController,
                    decoration: InputDecoration(
                      labelText: 'X',
                      labelStyle: TextStyle(fontSize: 8),
                      contentPadding: const EdgeInsets.all(4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    style: TextStyle(fontSize: 10),
                    onSubmitted: (value) {
                      if (widget.onUpdate != null) {
                        final updatedCropRegion = widget.cropRegion.copyWith(
                          x: double.tryParse(value),
                        );
                        widget.onUpdate!(
                          widget.cropRegion.id,
                          updatedCropRegion,
                        );
                      }
                    },
                    onTap: () {
                      if (widget.onSelected != null) {
                        widget.onSelected!(widget.cropRegion.id);
                      }
                    },
                  ),
                ),

                //Y
                SizedBox(
                  width: 50,
                  height: 20,
                  child: TextField(
                    controller: yController,
                    decoration: InputDecoration(
                      labelText: 'Y',
                      labelStyle: TextStyle(fontSize: 8),
                      contentPadding: const EdgeInsets.all(4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    style: TextStyle(fontSize: 10),
                    onSubmitted: (value) {
                      if (widget.onUpdate != null) {
                        final updatedCropRegion = widget.cropRegion.copyWith(
                          y: double.tryParse(value),
                        );
                        widget.onUpdate!(
                          widget.cropRegion.id,
                          updatedCropRegion,
                        );
                      }
                    },
                    onTap: () {
                      if (widget.onSelected != null) {
                        widget.onSelected!(widget.cropRegion.id);
                      }
                    },
                  ),
                ),

                //WIDTH
                SizedBox(
                  width: 50,
                  height: 20,
                  child: TextField(
                    controller: wController,
                    decoration: InputDecoration(
                      labelText: 'W',
                      labelStyle: TextStyle(fontSize: 8),
                      contentPadding: const EdgeInsets.all(4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    style: TextStyle(fontSize: 10),
                    onSubmitted: (value) {
                      if (widget.onUpdate != null) {
                        final updatedCropRegion = widget.cropRegion.copyWith(
                          width: double.tryParse(value),
                        );
                        widget.onUpdate!(
                          widget.cropRegion.id,
                          updatedCropRegion,
                        );
                      }
                    },
                    onTap: () {
                      if (widget.onSelected != null) {
                        widget.onSelected!(widget.cropRegion.id);
                      }
                    },
                  ),
                ),

                //HEIGHT
                SizedBox(
                  width: 50,
                  height: 20,
                  child: TextField(
                    controller: hController,
                    decoration: InputDecoration(
                      labelText: 'H',
                      labelStyle: TextStyle(fontSize: 8),
                      contentPadding: const EdgeInsets.all(4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    style: TextStyle(fontSize: 10),
                    onSubmitted: (value) {
                      if (widget.onUpdate != null) {
                        final updatedCropRegion = widget.cropRegion.copyWith(
                          height: double.tryParse(value),
                        );
                        widget.onUpdate!(
                          widget.cropRegion.id,
                          updatedCropRegion,
                        );
                      }
                    },
                    onTap: () {
                      if (widget.onSelected != null) {
                        widget.onSelected!(widget.cropRegion.id);
                      }
                    },
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onRemove != null) {
                      widget.onRemove!(widget.cropRegion.id);
                    }
                  },
                  icon: Icon(Icons.delete),
                  label: Text('DEL'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
