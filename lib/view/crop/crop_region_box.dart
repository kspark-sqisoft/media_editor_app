import 'package:flutter/material.dart';
import 'package:media_editor_app/main.dart';
import 'package:media_editor_app/view/crop/model/crop_region.dart';

typedef CropRegionUpdateCallback = void Function(int id, CropRegion region);

class CropRegionBox extends StatefulWidget {
  const CropRegionBox({
    super.key,
    required this.cropRegion,
    required this.isSelected,
    this.onRemove,
    this.onUpdate,
    this.onSelected,
  });
  final CropRegion cropRegion;
  final bool isSelected;
  final ValueChanged<int>? onRemove;
  final CropRegionUpdateCallback? onUpdate;
  final ValueChanged<int>? onSelected;

  @override
  State<CropRegionBox> createState() => _CropRegionBoxState();
}

class _CropRegionBoxState extends State<CropRegionBox> {
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
  void didUpdateWidget(covariant CropRegionBox oldWidget) {
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

  void _applyChanges() {
    if (widget.onUpdate != null) {
      final updatedCropRegion = widget.cropRegion.copyWith(
        name: nameController.text,
        x: double.tryParse(xController.text) ?? widget.cropRegion.x,
        y: double.tryParse(yController.text) ?? widget.cropRegion.y,
        width: double.tryParse(wController.text) ?? widget.cropRegion.width,
        height: double.tryParse(hController.text) ?? widget.cropRegion.height,
      );
      widget.onUpdate!(widget.cropRegion.id, updatedCropRegion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.isSelected
              ? Colors.green
              : Colors.white.withValues(alpha: 0.5),
        ),
        color: widget.isSelected
            ? Colors.red.withValues(alpha: 0.2)
            : widget.cropRegion.color!.withValues(alpha: 0.2),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          //이름
                          SizedBox(
                            width: 105,
                            height: 20,
                            child: TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withValues(
                                  alpha: .4,
                                ), // 반투명 배경
                                labelText: 'NAME',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                                contentPadding: const EdgeInsets.all(4),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                              ),
                              onSubmitted: (value) {
                                if (widget.onUpdate != null) {
                                  final updatedCropRegion = widget.cropRegion
                                      .copyWith(name: value);
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
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          //X
                          SizedBox(
                            width: 50,
                            height: 25,
                            child: TextField(
                              controller: xController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withValues(
                                  alpha: .4,
                                ), // 반투명 배경
                                labelText: 'X',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                                contentPadding: const EdgeInsets.all(4),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                              ),
                              onSubmitted: (value) {
                                if (widget.onUpdate != null) {
                                  final updatedCropRegion = widget.cropRegion
                                      .copyWith(x: double.tryParse(value));
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
                          SizedBox(width: 5),
                          //Y
                          SizedBox(
                            width: 50,
                            height: 25,
                            child: TextField(
                              controller: yController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withValues(
                                  alpha: .4,
                                ), // 반투명 배경
                                labelText: 'Y',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                                contentPadding: const EdgeInsets.all(4),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                              ),
                              onSubmitted: (value) {
                                if (widget.onUpdate != null) {
                                  final updatedCropRegion = widget.cropRegion
                                      .copyWith(y: double.tryParse(value));
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
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          //WIDTH
                          SizedBox(
                            width: 50,
                            height: 25,
                            child: TextField(
                              controller: wController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withValues(
                                  alpha: .4,
                                ), // 반투명 배경
                                labelText: 'W',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                                contentPadding: const EdgeInsets.all(4),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                              ),
                              onSubmitted: (value) {
                                if (widget.onUpdate != null) {
                                  final updatedCropRegion = widget.cropRegion
                                      .copyWith(width: double.tryParse(value));
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
                          SizedBox(width: 5),
                          //HEIGHT
                          SizedBox(
                            width: 50,
                            height: 25,
                            child: TextField(
                              controller: hController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withValues(
                                  alpha: .4,
                                ), // 반투명 배경
                                labelText: 'H',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                                contentPadding: const EdgeInsets.all(4),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                              ),
                              onSubmitted: (value) {
                                if (widget.onUpdate != null) {
                                  final updatedCropRegion = widget.cropRegion
                                      .copyWith(height: double.tryParse(value));
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
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _applyChanges();
                            },
                            icon: Icon(Icons.published_with_changes, size: 18),
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.blue.withValues(alpha: 0.5),
                              ), // Flutter 3.22+
                            ),
                          ),
                          SizedBox(width: 5),
                          IconButton(
                            onPressed: () {
                              if (widget.onRemove != null) {
                                widget.onRemove!(widget.cropRegion.id);
                              }
                            },
                            icon: Icon(Icons.delete, size: 18),
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.red.withValues(alpha: 0.5),
                              ), // Flutter 3.22+
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
