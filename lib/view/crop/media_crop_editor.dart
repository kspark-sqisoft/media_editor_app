import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:media_editor_app/main.dart';
import 'package:media_editor_app/urtil/utils.dart';
import 'package:media_editor_app/view/crop/crop_region_box.dart';
import 'package:media_editor_app/view/crop/image_player.dart';
import 'package:media_editor_app/view/crop/model/crop_region.dart';
import 'package:media_editor_app/view/crop/setting_panel.dart';
import 'package:media_editor_app/view/crop/video_player.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';

enum MediaType { image, video, unknowon }

class MediaCropEditor extends StatefulWidget {
  const MediaCropEditor({super.key});

  @override
  State<MediaCropEditor> createState() => _MediaCropEditorState();
}

class _MediaCropEditorState extends State<MediaCropEditor> {
  Uint8List? _mediaBytes;
  MediaType? _mediaType;
  String? _mediaName;
  String? _mediaPath;
  Size? _mediaSize;
  Duration? _mediaDuration;

  final List<CropRegion> _cropRegions = [];
  int _nextRegionId = 1;
  int? _selectedRegionId;

  bool _isSettingsPanelOpen = false;

  final GlobalKey _fittedBoxKey = GlobalKey();
  Size? _fittedBoxSize;

  void _getFittedBoxSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _fittedBoxKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          _fittedBoxSize = renderBox.size;
        });
        logger.d('FittedBox size: $_fittedBoxSize');
      }
    });
  }

  void _addCropRegion() {
    final newCropRegion = CropRegion(
      id: _nextRegionId,
      name: 'area $_nextRegionId',
      x: 0,
      y: 0,
      width: 200,
      height: 200,
      color: Utils.generateRandomColor(),
    );

    setState(() {
      _cropRegions.add(newCropRegion);
      _nextRegionId++;
      _selectedRegionId = newCropRegion.id;
    });
  }

  void _removeCropRegion(int id) {
    setState(() {
      _cropRegions.removeWhere((region) => region.id == id);

      // 만약 선택된 영역이 삭제된 영역이라면 선택 해제
      if (_selectedRegionId == id) {
        _selectedRegionId = null;
      }
    });
  }

  void _selectCropRegion(int regionId) {
    setState(() {
      _selectedRegionId = regionId;
    });
  }

  void _updateCropRegionById(int id, CropRegion newRegion) {
    final index = _cropRegions.indexWhere((r) => r.id == id);
    if (index != -1) {
      setState(() {
        _cropRegions[index] = newRegion;
      });
    }

    //logger.d('UPDATED $_cropRegions');
  }

  void _reset() {
    setState(() {
      _mediaBytes = null;
      _mediaType = null;
      _mediaSize = null;
      _mediaDuration = null;
      _mediaName = null;
      _mediaPath = null;

      _cropRegions.clear();
      _nextRegionId = 1;
      _selectedRegionId = null;
      _isSettingsPanelOpen = false;
      _fittedBoxSize = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DropTarget(
          onDragDone: (details) async {
            _reset();
            if (details.files.isNotEmpty) {
              final DropItemFile file = details.files.first as DropItemFile;
              logger.d('Drop File #########');
              logger.d('file:$file');
              logger.d('file.name:${file.name}');
              logger.d('file.mimeType:${file.mimeType}');
              logger.d('file.path: ${file.path}');

              _mediaName = file.name;
              _mediaPath = file.path;

              _mediaBytes = await file.readAsBytes();
              //바이트 분석을 통한 mimeType 결정
              final mimeType = Utils.detectMimeTypeFromBytes(_mediaBytes!);
              logger.d('mimeType:$mimeType');
              if (mimeType!.contains('image')) {
                _mediaType = MediaType.image;
              } else if (mimeType.contains('video')) {
                _mediaType = MediaType.video;
              } else {
                _mediaType = MediaType.unknowon;
              }
              logger.d('_mediaType:$_mediaType');

              setState(() {});
            }
          },
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              //설명 영역
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upload, size: 36, color: Colors.blue),
                    Text(
                      '파일을 여기로 드래그하세요.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              FittedBox(
                key: _fittedBoxKey,
                child: Stack(
                  children: [
                    //미디어 영역
                    if (_mediaBytes != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRegionId = null;
                          });
                        },
                        child: _mediaType == MediaType.image
                            ? ImagePlayer(
                                key: ValueKey(_mediaBytes!.hashCode),
                                bytes: _mediaBytes!,
                                onImageSize: (value) {
                                  setState(() {
                                    _mediaSize = value;
                                    logger.d('_mediaSize:$_mediaSize');
                                    _getFittedBoxSize();
                                  });
                                },
                              )
                            : _mediaType == MediaType.video
                            ? VideoPlayer(
                                key: ValueKey(_mediaBytes!.hashCode),
                                bytes: _mediaBytes!,
                                onVideoSize: (value) {
                                  setState(() {
                                    _mediaSize = value;
                                    logger.d('_mediaSize:$_mediaSize');
                                    _getFittedBoxSize();
                                  });
                                },
                                onVideoDuration: (value) {
                                  setState(() {
                                    _mediaDuration = value;
                                  });
                                },
                              )
                            : SizedBox.shrink(),
                      ),

                    //선택 영역
                    if (_mediaSize != null)
                      SizedBox(
                        width: _mediaSize!.width,
                        height: _mediaSize!.height,
                        child: Stack(
                          children: [
                            ...(() {
                              final sortedEntries = _cropRegions
                                  .asMap()
                                  .entries
                                  .toList();
                              //선택 된거 최상위
                              sortedEntries.sort((a, b) {
                                // 선택된 영역을 마지막에 배치하여 Stack에서 최상위가 되도록 함
                                final aIsSelected =
                                    _selectedRegionId == a.value.id;
                                final bIsSelected =
                                    _selectedRegionId == b.value.id;

                                if (aIsSelected && !bIsSelected) {
                                  return 1; // a가 선택됨, b가 선택되지 않음 -> a를 뒤로
                                }

                                if (!aIsSelected && bIsSelected) {
                                  return -1; // a가 선택되지 않음, b가 선택됨 -> b를 뒤로
                                }
                                return 0; // 둘 다 선택되거나 둘 다 선택되지 않음 -> 순서 유지
                              });

                              // FittedBox scale 계산
                              double scaleFactor = 1;
                              if (_fittedBoxSize != null &&
                                  _mediaSize != null) {
                                scaleFactor =
                                    _fittedBoxSize!.width / _mediaSize!.width;
                              }

                              return sortedEntries.map((entry) {
                                final index = entry.key;
                                final region = entry.value;
                                final isSelected =
                                    _selectedRegionId == region.id;

                                return TransformableBox(
                                  key: ValueKey('crop_region_${region.id}'),
                                  rect: Rect.fromLTWH(
                                    // 상대 좌표를 실제 화면 좌표로 변환
                                    region.x,
                                    region.y,
                                    region.width,
                                    region.height,
                                  ),
                                  clampingRect: Rect.fromLTWH(
                                    0,
                                    0,
                                    _mediaSize!.width,
                                    _mediaSize!.height,
                                  ),
                                  onChanged: (result, event) {
                                    final updatedRegion = region.copyWith(
                                      x: result.rect.left,
                                      y: result.rect.top,
                                      width: result.rect.width,
                                      height: result.rect.height,
                                    );
                                    //_updateCropRegion(index, updatedRegion);
                                    _updateCropRegionById(
                                      region.id,
                                      updatedRegion,
                                    );
                                  },
                                  onDragStart: (event) {
                                    _selectCropRegion(region.id);
                                  },
                                  onResizeStart: (handle, event) {
                                    _selectCropRegion(region.id);
                                  },
                                  onTap: () {
                                    _selectCropRegion(region.id);
                                  },
                                  contentBuilder: (context, rect, flip) {
                                    return CropRegionBox(
                                      cropRegion: region,
                                      isSelected: isSelected,
                                      onRemove: (value) {
                                        _removeCropRegion(value);
                                      },
                                      onUpdate: (id, cropRegion) {
                                        _updateCropRegionById(id, cropRegion);
                                      },
                                      onSelected: (value) {
                                        _selectCropRegion(value);
                                      },
                                    );
                                  },
                                  //코너 핸들
                                  cornerHandleBuilder: (context, handle) {
                                    return DefaultCornerHandle(
                                      handle: handle,
                                      size: isSelected ? 12 : 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                      ),
                                    );
                                  },
                                  //사이드 핸들
                                  sideHandleBuilder: (context, handle) {
                                    return DefaultSideHandle(
                                      handle: handle,
                                      length: isSelected ? 12 : 8,
                                      thickness: isSelected ? 12 : 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                      ),
                                    );
                                  },
                                );
                              }).toList();
                            })(),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              //설정 패널
              if (_mediaSize != null)
                Align(
                  alignment: Alignment.topRight,
                  child: //UI
                  SettingPanel(
                    cropRegions: _cropRegions,
                    onAdd: _addCropRegion,
                    isSettingsPanelOpen: _isSettingsPanelOpen,
                    selectedRegionId: _selectedRegionId,
                    onSelected: (value) {
                      _selectCropRegion(value);
                    },
                    onInSettingsPanelChanged: (value) {
                      setState(() {
                        _isSettingsPanelOpen = value;
                      });
                    },
                    onUpdate: _updateCropRegionById,
                    onRemove: _removeCropRegion,
                  ),
                ),
              //미디어 정보
              if (_mediaSize != null)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_mediaName != null)
                          Text(
                            '$_mediaName',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        if (_mediaPath != null)
                          Text(
                            '$_mediaPath',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        Text(
                          '${_mediaSize!.width} x ${_mediaSize!.height}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_mediaDuration != null)
                          Text(
                            '${_mediaDuration!.inMilliseconds}ms  ${Utils.formatDuration(_mediaDuration!.inMilliseconds)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
