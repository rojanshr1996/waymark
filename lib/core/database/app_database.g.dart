// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TripAlbumsTable extends TripAlbums
    with TableInfo<$TripAlbumsTable, TripAlbum> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripAlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverImagePathMeta = const VerificationMeta(
    'coverImagePath',
  );
  @override
  late final GeneratedColumn<String> coverImagePath = GeneratedColumn<String>(
    'cover_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ONGOING'),
  );
  static const VerificationMeta _totalDistanceKmMeta = const VerificationMeta(
    'totalDistanceKm',
  );
  @override
  late final GeneratedColumn<double> totalDistanceKm = GeneratedColumn<double>(
    'total_distance_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalPlacesCountMeta = const VerificationMeta(
    'totalPlacesCount',
  );
  @override
  late final GeneratedColumn<int> totalPlacesCount = GeneratedColumn<int>(
    'total_places_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    startDate,
    endDate,
    coverImagePath,
    status,
    totalDistanceKm,
    totalPlacesCount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripAlbum> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('cover_image_path')) {
      context.handle(
        _coverImagePathMeta,
        coverImagePath.isAcceptableOrUnknown(
          data['cover_image_path']!,
          _coverImagePathMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('total_distance_km')) {
      context.handle(
        _totalDistanceKmMeta,
        totalDistanceKm.isAcceptableOrUnknown(
          data['total_distance_km']!,
          _totalDistanceKmMeta,
        ),
      );
    }
    if (data.containsKey('total_places_count')) {
      context.handle(
        _totalPlacesCountMeta,
        totalPlacesCount.isAcceptableOrUnknown(
          data['total_places_count']!,
          _totalPlacesCountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripAlbum map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripAlbum(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      coverImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image_path'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      totalDistanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_distance_km'],
      )!,
      totalPlacesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_places_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TripAlbumsTable createAlias(String alias) {
    return $TripAlbumsTable(attachedDatabase, alias);
  }
}

class TripAlbum extends DataClass implements Insertable<TripAlbum> {
  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String? coverImagePath;
  final String status;
  final double totalDistanceKm;
  final int totalPlacesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TripAlbum({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    this.endDate,
    this.coverImagePath,
    required this.status,
    required this.totalDistanceKm,
    required this.totalPlacesCount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || coverImagePath != null) {
      map['cover_image_path'] = Variable<String>(coverImagePath);
    }
    map['status'] = Variable<String>(status);
    map['total_distance_km'] = Variable<double>(totalDistanceKm);
    map['total_places_count'] = Variable<int>(totalPlacesCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TripAlbumsCompanion toCompanion(bool nullToAbsent) {
    return TripAlbumsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      coverImagePath: coverImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImagePath),
      status: Value(status),
      totalDistanceKm: Value(totalDistanceKm),
      totalPlacesCount: Value(totalPlacesCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TripAlbum.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripAlbum(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      coverImagePath: serializer.fromJson<String?>(json['coverImagePath']),
      status: serializer.fromJson<String>(json['status']),
      totalDistanceKm: serializer.fromJson<double>(json['totalDistanceKm']),
      totalPlacesCount: serializer.fromJson<int>(json['totalPlacesCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'coverImagePath': serializer.toJson<String?>(coverImagePath),
      'status': serializer.toJson<String>(status),
      'totalDistanceKm': serializer.toJson<double>(totalDistanceKm),
      'totalPlacesCount': serializer.toJson<int>(totalPlacesCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TripAlbum copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    Value<String?> coverImagePath = const Value.absent(),
    String? status,
    double? totalDistanceKm,
    int? totalPlacesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TripAlbum(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    coverImagePath: coverImagePath.present
        ? coverImagePath.value
        : this.coverImagePath,
    status: status ?? this.status,
    totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
    totalPlacesCount: totalPlacesCount ?? this.totalPlacesCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TripAlbum copyWithCompanion(TripAlbumsCompanion data) {
    return TripAlbum(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      coverImagePath: data.coverImagePath.present
          ? data.coverImagePath.value
          : this.coverImagePath,
      status: data.status.present ? data.status.value : this.status,
      totalDistanceKm: data.totalDistanceKm.present
          ? data.totalDistanceKm.value
          : this.totalDistanceKm,
      totalPlacesCount: data.totalPlacesCount.present
          ? data.totalPlacesCount.value
          : this.totalPlacesCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripAlbum(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('status: $status, ')
          ..write('totalDistanceKm: $totalDistanceKm, ')
          ..write('totalPlacesCount: $totalPlacesCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    startDate,
    endDate,
    coverImagePath,
    status,
    totalDistanceKm,
    totalPlacesCount,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripAlbum &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.coverImagePath == this.coverImagePath &&
          other.status == this.status &&
          other.totalDistanceKm == this.totalDistanceKm &&
          other.totalPlacesCount == this.totalPlacesCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TripAlbumsCompanion extends UpdateCompanion<TripAlbum> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<String?> coverImagePath;
  final Value<String> status;
  final Value<double> totalDistanceKm;
  final Value<int> totalPlacesCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TripAlbumsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.status = const Value.absent(),
    this.totalDistanceKm = const Value.absent(),
    this.totalPlacesCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripAlbumsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.status = const Value.absent(),
    this.totalDistanceKm = const Value.absent(),
    this.totalPlacesCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       startDate = Value(startDate);
  static Insertable<TripAlbum> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? coverImagePath,
    Expression<String>? status,
    Expression<double>? totalDistanceKm,
    Expression<int>? totalPlacesCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (coverImagePath != null) 'cover_image_path': coverImagePath,
      if (status != null) 'status': status,
      if (totalDistanceKm != null) 'total_distance_km': totalDistanceKm,
      if (totalPlacesCount != null) 'total_places_count': totalPlacesCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripAlbumsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<String?>? coverImagePath,
    Value<String>? status,
    Value<double>? totalDistanceKm,
    Value<int>? totalPlacesCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TripAlbumsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      status: status ?? this.status,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalPlacesCount: totalPlacesCount ?? this.totalPlacesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (coverImagePath.present) {
      map['cover_image_path'] = Variable<String>(coverImagePath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalDistanceKm.present) {
      map['total_distance_km'] = Variable<double>(totalDistanceKm.value);
    }
    if (totalPlacesCount.present) {
      map['total_places_count'] = Variable<int>(totalPlacesCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripAlbumsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('status: $status, ')
          ..write('totalDistanceKm: $totalDistanceKm, ')
          ..write('totalPlacesCount: $totalPlacesCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripPlacesTable extends TripPlaces
    with TableInfo<$TripPlacesTable, TripPlace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripPlacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trip_albums (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visitedAtMeta = const VerificationMeta(
    'visitedAt',
  );
  @override
  late final GeneratedColumn<DateTime> visitedAt = GeneratedColumn<DateTime>(
    'visited_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitOrderMeta = const VerificationMeta(
    'visitOrder',
  );
  @override
  late final GeneratedColumn<int> visitOrder = GeneratedColumn<int>(
    'visit_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weatherConditionMeta = const VerificationMeta(
    'weatherCondition',
  );
  @override
  late final GeneratedColumn<String> weatherCondition = GeneratedColumn<String>(
    'weather_condition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureCelsiusMeta =
      const VerificationMeta('temperatureCelsius');
  @override
  late final GeneratedColumn<double> temperatureCelsius =
      GeneratedColumn<double>(
        'temperature_celsius',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GENERAL'),
  );
  static const VerificationMeta _locationAddressMeta = const VerificationMeta(
    'locationAddress',
  );
  @override
  late final GeneratedColumn<String> locationAddress = GeneratedColumn<String>(
    'location_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sensoryTagsMeta = const VerificationMeta(
    'sensoryTags',
  );
  @override
  late final GeneratedColumn<String> sensoryTags = GeneratedColumn<String>(
    'sensory_tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isGpsFromExifMeta = const VerificationMeta(
    'isGpsFromExif',
  );
  @override
  late final GeneratedColumn<bool> isGpsFromExif = GeneratedColumn<bool>(
    'is_gps_from_exif',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_gps_from_exif" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    albumId,
    name,
    notes,
    latitude,
    longitude,
    altitude,
    visitedAt,
    visitOrder,
    weatherCondition,
    temperatureCelsius,
    category,
    locationAddress,
    sensoryTags,
    isGpsFromExif,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_places';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripPlace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('visited_at')) {
      context.handle(
        _visitedAtMeta,
        visitedAt.isAcceptableOrUnknown(data['visited_at']!, _visitedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_visitedAtMeta);
    }
    if (data.containsKey('visit_order')) {
      context.handle(
        _visitOrderMeta,
        visitOrder.isAcceptableOrUnknown(data['visit_order']!, _visitOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_visitOrderMeta);
    }
    if (data.containsKey('weather_condition')) {
      context.handle(
        _weatherConditionMeta,
        weatherCondition.isAcceptableOrUnknown(
          data['weather_condition']!,
          _weatherConditionMeta,
        ),
      );
    }
    if (data.containsKey('temperature_celsius')) {
      context.handle(
        _temperatureCelsiusMeta,
        temperatureCelsius.isAcceptableOrUnknown(
          data['temperature_celsius']!,
          _temperatureCelsiusMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('location_address')) {
      context.handle(
        _locationAddressMeta,
        locationAddress.isAcceptableOrUnknown(
          data['location_address']!,
          _locationAddressMeta,
        ),
      );
    }
    if (data.containsKey('sensory_tags')) {
      context.handle(
        _sensoryTagsMeta,
        sensoryTags.isAcceptableOrUnknown(
          data['sensory_tags']!,
          _sensoryTagsMeta,
        ),
      );
    }
    if (data.containsKey('is_gps_from_exif')) {
      context.handle(
        _isGpsFromExifMeta,
        isGpsFromExif.isAcceptableOrUnknown(
          data['is_gps_from_exif']!,
          _isGpsFromExifMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripPlace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripPlace(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      visitedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}visited_at'],
      )!,
      visitOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visit_order'],
      )!,
      weatherCondition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather_condition'],
      ),
      temperatureCelsius: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature_celsius'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      locationAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_address'],
      ),
      sensoryTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sensory_tags'],
      ),
      isGpsFromExif: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_gps_from_exif'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TripPlacesTable createAlias(String alias) {
    return $TripPlacesTable(attachedDatabase, alias);
  }
}

class TripPlace extends DataClass implements Insertable<TripPlace> {
  final String id;
  final String albumId;
  final String name;
  final String? notes;
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime visitedAt;
  final int visitOrder;
  final String? weatherCondition;
  final double? temperatureCelsius;
  final String category;
  final String? locationAddress;
  final String? sensoryTags;
  final bool isGpsFromExif;
  final DateTime createdAt;
  const TripPlace({
    required this.id,
    required this.albumId,
    required this.name,
    this.notes,
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.visitedAt,
    required this.visitOrder,
    this.weatherCondition,
    this.temperatureCelsius,
    required this.category,
    this.locationAddress,
    this.sensoryTags,
    required this.isGpsFromExif,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['album_id'] = Variable<String>(albumId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    map['visited_at'] = Variable<DateTime>(visitedAt);
    map['visit_order'] = Variable<int>(visitOrder);
    if (!nullToAbsent || weatherCondition != null) {
      map['weather_condition'] = Variable<String>(weatherCondition);
    }
    if (!nullToAbsent || temperatureCelsius != null) {
      map['temperature_celsius'] = Variable<double>(temperatureCelsius);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || locationAddress != null) {
      map['location_address'] = Variable<String>(locationAddress);
    }
    if (!nullToAbsent || sensoryTags != null) {
      map['sensory_tags'] = Variable<String>(sensoryTags);
    }
    map['is_gps_from_exif'] = Variable<bool>(isGpsFromExif);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TripPlacesCompanion toCompanion(bool nullToAbsent) {
    return TripPlacesCompanion(
      id: Value(id),
      albumId: Value(albumId),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      visitedAt: Value(visitedAt),
      visitOrder: Value(visitOrder),
      weatherCondition: weatherCondition == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherCondition),
      temperatureCelsius: temperatureCelsius == null && nullToAbsent
          ? const Value.absent()
          : Value(temperatureCelsius),
      category: Value(category),
      locationAddress: locationAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(locationAddress),
      sensoryTags: sensoryTags == null && nullToAbsent
          ? const Value.absent()
          : Value(sensoryTags),
      isGpsFromExif: Value(isGpsFromExif),
      createdAt: Value(createdAt),
    );
  }

  factory TripPlace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripPlace(
      id: serializer.fromJson<String>(json['id']),
      albumId: serializer.fromJson<String>(json['albumId']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      visitedAt: serializer.fromJson<DateTime>(json['visitedAt']),
      visitOrder: serializer.fromJson<int>(json['visitOrder']),
      weatherCondition: serializer.fromJson<String?>(json['weatherCondition']),
      temperatureCelsius: serializer.fromJson<double?>(
        json['temperatureCelsius'],
      ),
      category: serializer.fromJson<String>(json['category']),
      locationAddress: serializer.fromJson<String?>(json['locationAddress']),
      sensoryTags: serializer.fromJson<String?>(json['sensoryTags']),
      isGpsFromExif: serializer.fromJson<bool>(json['isGpsFromExif']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'albumId': serializer.toJson<String>(albumId),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitude': serializer.toJson<double?>(altitude),
      'visitedAt': serializer.toJson<DateTime>(visitedAt),
      'visitOrder': serializer.toJson<int>(visitOrder),
      'weatherCondition': serializer.toJson<String?>(weatherCondition),
      'temperatureCelsius': serializer.toJson<double?>(temperatureCelsius),
      'category': serializer.toJson<String>(category),
      'locationAddress': serializer.toJson<String?>(locationAddress),
      'sensoryTags': serializer.toJson<String?>(sensoryTags),
      'isGpsFromExif': serializer.toJson<bool>(isGpsFromExif),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TripPlace copyWith({
    String? id,
    String? albumId,
    String? name,
    Value<String?> notes = const Value.absent(),
    double? latitude,
    double? longitude,
    Value<double?> altitude = const Value.absent(),
    DateTime? visitedAt,
    int? visitOrder,
    Value<String?> weatherCondition = const Value.absent(),
    Value<double?> temperatureCelsius = const Value.absent(),
    String? category,
    Value<String?> locationAddress = const Value.absent(),
    Value<String?> sensoryTags = const Value.absent(),
    bool? isGpsFromExif,
    DateTime? createdAt,
  }) => TripPlace(
    id: id ?? this.id,
    albumId: albumId ?? this.albumId,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitude: altitude.present ? altitude.value : this.altitude,
    visitedAt: visitedAt ?? this.visitedAt,
    visitOrder: visitOrder ?? this.visitOrder,
    weatherCondition: weatherCondition.present
        ? weatherCondition.value
        : this.weatherCondition,
    temperatureCelsius: temperatureCelsius.present
        ? temperatureCelsius.value
        : this.temperatureCelsius,
    category: category ?? this.category,
    locationAddress: locationAddress.present
        ? locationAddress.value
        : this.locationAddress,
    sensoryTags: sensoryTags.present ? sensoryTags.value : this.sensoryTags,
    isGpsFromExif: isGpsFromExif ?? this.isGpsFromExif,
    createdAt: createdAt ?? this.createdAt,
  );
  TripPlace copyWithCompanion(TripPlacesCompanion data) {
    return TripPlace(
      id: data.id.present ? data.id.value : this.id,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      visitedAt: data.visitedAt.present ? data.visitedAt.value : this.visitedAt,
      visitOrder: data.visitOrder.present
          ? data.visitOrder.value
          : this.visitOrder,
      weatherCondition: data.weatherCondition.present
          ? data.weatherCondition.value
          : this.weatherCondition,
      temperatureCelsius: data.temperatureCelsius.present
          ? data.temperatureCelsius.value
          : this.temperatureCelsius,
      category: data.category.present ? data.category.value : this.category,
      locationAddress: data.locationAddress.present
          ? data.locationAddress.value
          : this.locationAddress,
      sensoryTags: data.sensoryTags.present
          ? data.sensoryTags.value
          : this.sensoryTags,
      isGpsFromExif: data.isGpsFromExif.present
          ? data.isGpsFromExif.value
          : this.isGpsFromExif,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripPlace(')
          ..write('id: $id, ')
          ..write('albumId: $albumId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('visitOrder: $visitOrder, ')
          ..write('weatherCondition: $weatherCondition, ')
          ..write('temperatureCelsius: $temperatureCelsius, ')
          ..write('category: $category, ')
          ..write('locationAddress: $locationAddress, ')
          ..write('sensoryTags: $sensoryTags, ')
          ..write('isGpsFromExif: $isGpsFromExif, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    albumId,
    name,
    notes,
    latitude,
    longitude,
    altitude,
    visitedAt,
    visitOrder,
    weatherCondition,
    temperatureCelsius,
    category,
    locationAddress,
    sensoryTags,
    isGpsFromExif,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripPlace &&
          other.id == this.id &&
          other.albumId == this.albumId &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude &&
          other.visitedAt == this.visitedAt &&
          other.visitOrder == this.visitOrder &&
          other.weatherCondition == this.weatherCondition &&
          other.temperatureCelsius == this.temperatureCelsius &&
          other.category == this.category &&
          other.locationAddress == this.locationAddress &&
          other.sensoryTags == this.sensoryTags &&
          other.isGpsFromExif == this.isGpsFromExif &&
          other.createdAt == this.createdAt);
}

class TripPlacesCompanion extends UpdateCompanion<TripPlace> {
  final Value<String> id;
  final Value<String> albumId;
  final Value<String> name;
  final Value<String?> notes;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> altitude;
  final Value<DateTime> visitedAt;
  final Value<int> visitOrder;
  final Value<String?> weatherCondition;
  final Value<double?> temperatureCelsius;
  final Value<String> category;
  final Value<String?> locationAddress;
  final Value<String?> sensoryTags;
  final Value<bool> isGpsFromExif;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TripPlacesCompanion({
    this.id = const Value.absent(),
    this.albumId = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.visitedAt = const Value.absent(),
    this.visitOrder = const Value.absent(),
    this.weatherCondition = const Value.absent(),
    this.temperatureCelsius = const Value.absent(),
    this.category = const Value.absent(),
    this.locationAddress = const Value.absent(),
    this.sensoryTags = const Value.absent(),
    this.isGpsFromExif = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripPlacesCompanion.insert({
    required String id,
    required String albumId,
    required String name,
    this.notes = const Value.absent(),
    required double latitude,
    required double longitude,
    this.altitude = const Value.absent(),
    required DateTime visitedAt,
    required int visitOrder,
    this.weatherCondition = const Value.absent(),
    this.temperatureCelsius = const Value.absent(),
    this.category = const Value.absent(),
    this.locationAddress = const Value.absent(),
    this.sensoryTags = const Value.absent(),
    this.isGpsFromExif = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       albumId = Value(albumId),
       name = Value(name),
       latitude = Value(latitude),
       longitude = Value(longitude),
       visitedAt = Value(visitedAt),
       visitOrder = Value(visitOrder);
  static Insertable<TripPlace> custom({
    Expression<String>? id,
    Expression<String>? albumId,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitude,
    Expression<DateTime>? visitedAt,
    Expression<int>? visitOrder,
    Expression<String>? weatherCondition,
    Expression<double>? temperatureCelsius,
    Expression<String>? category,
    Expression<String>? locationAddress,
    Expression<String>? sensoryTags,
    Expression<bool>? isGpsFromExif,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (albumId != null) 'album_id': albumId,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (visitedAt != null) 'visited_at': visitedAt,
      if (visitOrder != null) 'visit_order': visitOrder,
      if (weatherCondition != null) 'weather_condition': weatherCondition,
      if (temperatureCelsius != null) 'temperature_celsius': temperatureCelsius,
      if (category != null) 'category': category,
      if (locationAddress != null) 'location_address': locationAddress,
      if (sensoryTags != null) 'sensory_tags': sensoryTags,
      if (isGpsFromExif != null) 'is_gps_from_exif': isGpsFromExif,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripPlacesCompanion copyWith({
    Value<String>? id,
    Value<String>? albumId,
    Value<String>? name,
    Value<String?>? notes,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? altitude,
    Value<DateTime>? visitedAt,
    Value<int>? visitOrder,
    Value<String?>? weatherCondition,
    Value<double?>? temperatureCelsius,
    Value<String>? category,
    Value<String?>? locationAddress,
    Value<String?>? sensoryTags,
    Value<bool>? isGpsFromExif,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TripPlacesCompanion(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      visitedAt: visitedAt ?? this.visitedAt,
      visitOrder: visitOrder ?? this.visitOrder,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      category: category ?? this.category,
      locationAddress: locationAddress ?? this.locationAddress,
      sensoryTags: sensoryTags ?? this.sensoryTags,
      isGpsFromExif: isGpsFromExif ?? this.isGpsFromExif,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (visitedAt.present) {
      map['visited_at'] = Variable<DateTime>(visitedAt.value);
    }
    if (visitOrder.present) {
      map['visit_order'] = Variable<int>(visitOrder.value);
    }
    if (weatherCondition.present) {
      map['weather_condition'] = Variable<String>(weatherCondition.value);
    }
    if (temperatureCelsius.present) {
      map['temperature_celsius'] = Variable<double>(temperatureCelsius.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (locationAddress.present) {
      map['location_address'] = Variable<String>(locationAddress.value);
    }
    if (sensoryTags.present) {
      map['sensory_tags'] = Variable<String>(sensoryTags.value);
    }
    if (isGpsFromExif.present) {
      map['is_gps_from_exif'] = Variable<bool>(isGpsFromExif.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripPlacesCompanion(')
          ..write('id: $id, ')
          ..write('albumId: $albumId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('visitOrder: $visitOrder, ')
          ..write('weatherCondition: $weatherCondition, ')
          ..write('temperatureCelsius: $temperatureCelsius, ')
          ..write('category: $category, ')
          ..write('locationAddress: $locationAddress, ')
          ..write('sensoryTags: $sensoryTags, ')
          ..write('isGpsFromExif: $isGpsFromExif, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaceMediaFilesTable extends PlaceMediaFiles
    with TableInfo<$PlaceMediaFilesTable, PlaceMediaFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaceMediaFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeIdMeta = const VerificationMeta(
    'placeId',
  );
  @override
  late final GeneratedColumn<String> placeId = GeneratedColumn<String>(
    'place_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trip_places (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCoverPhotoMeta = const VerificationMeta(
    'isCoverPhoto',
  );
  @override
  late final GeneratedColumn<bool> isCoverPhoto = GeneratedColumn<bool>(
    'is_cover_photo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_cover_photo" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    placeId,
    localFilePath,
    thumbnailPath,
    fileSizeBytes,
    width,
    height,
    isCoverPhoto,
    capturedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'place_media_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaceMediaFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('place_id')) {
      context.handle(
        _placeIdMeta,
        placeId.isAcceptableOrUnknown(data['place_id']!, _placeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_placeIdMeta);
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localFilePathMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_thumbnailPathMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileSizeBytesMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('is_cover_photo')) {
      context.handle(
        _isCoverPhotoMeta,
        isCoverPhoto.isAcceptableOrUnknown(
          data['is_cover_photo']!,
          _isCoverPhotoMeta,
        ),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaceMediaFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaceMediaFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      placeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_id'],
      )!,
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      )!,
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      )!,
      isCoverPhoto: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_cover_photo'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      ),
    );
  }

  @override
  $PlaceMediaFilesTable createAlias(String alias) {
    return $PlaceMediaFilesTable(attachedDatabase, alias);
  }
}

class PlaceMediaFile extends DataClass implements Insertable<PlaceMediaFile> {
  final String id;
  final String placeId;
  final String localFilePath;
  final String thumbnailPath;
  final int fileSizeBytes;
  final int width;
  final int height;
  final bool isCoverPhoto;
  final DateTime? capturedAt;
  const PlaceMediaFile({
    required this.id,
    required this.placeId,
    required this.localFilePath,
    required this.thumbnailPath,
    required this.fileSizeBytes,
    required this.width,
    required this.height,
    required this.isCoverPhoto,
    this.capturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['place_id'] = Variable<String>(placeId);
    map['local_file_path'] = Variable<String>(localFilePath);
    map['thumbnail_path'] = Variable<String>(thumbnailPath);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['is_cover_photo'] = Variable<bool>(isCoverPhoto);
    if (!nullToAbsent || capturedAt != null) {
      map['captured_at'] = Variable<DateTime>(capturedAt);
    }
    return map;
  }

  PlaceMediaFilesCompanion toCompanion(bool nullToAbsent) {
    return PlaceMediaFilesCompanion(
      id: Value(id),
      placeId: Value(placeId),
      localFilePath: Value(localFilePath),
      thumbnailPath: Value(thumbnailPath),
      fileSizeBytes: Value(fileSizeBytes),
      width: Value(width),
      height: Value(height),
      isCoverPhoto: Value(isCoverPhoto),
      capturedAt: capturedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedAt),
    );
  }

  factory PlaceMediaFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaceMediaFile(
      id: serializer.fromJson<String>(json['id']),
      placeId: serializer.fromJson<String>(json['placeId']),
      localFilePath: serializer.fromJson<String>(json['localFilePath']),
      thumbnailPath: serializer.fromJson<String>(json['thumbnailPath']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      isCoverPhoto: serializer.fromJson<bool>(json['isCoverPhoto']),
      capturedAt: serializer.fromJson<DateTime?>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'placeId': serializer.toJson<String>(placeId),
      'localFilePath': serializer.toJson<String>(localFilePath),
      'thumbnailPath': serializer.toJson<String>(thumbnailPath),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'isCoverPhoto': serializer.toJson<bool>(isCoverPhoto),
      'capturedAt': serializer.toJson<DateTime?>(capturedAt),
    };
  }

  PlaceMediaFile copyWith({
    String? id,
    String? placeId,
    String? localFilePath,
    String? thumbnailPath,
    int? fileSizeBytes,
    int? width,
    int? height,
    bool? isCoverPhoto,
    Value<DateTime?> capturedAt = const Value.absent(),
  }) => PlaceMediaFile(
    id: id ?? this.id,
    placeId: placeId ?? this.placeId,
    localFilePath: localFilePath ?? this.localFilePath,
    thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    width: width ?? this.width,
    height: height ?? this.height,
    isCoverPhoto: isCoverPhoto ?? this.isCoverPhoto,
    capturedAt: capturedAt.present ? capturedAt.value : this.capturedAt,
  );
  PlaceMediaFile copyWithCompanion(PlaceMediaFilesCompanion data) {
    return PlaceMediaFile(
      id: data.id.present ? data.id.value : this.id,
      placeId: data.placeId.present ? data.placeId.value : this.placeId,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      isCoverPhoto: data.isCoverPhoto.present
          ? data.isCoverPhoto.value
          : this.isCoverPhoto,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaceMediaFile(')
          ..write('id: $id, ')
          ..write('placeId: $placeId, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('isCoverPhoto: $isCoverPhoto, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    placeId,
    localFilePath,
    thumbnailPath,
    fileSizeBytes,
    width,
    height,
    isCoverPhoto,
    capturedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaceMediaFile &&
          other.id == this.id &&
          other.placeId == this.placeId &&
          other.localFilePath == this.localFilePath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.width == this.width &&
          other.height == this.height &&
          other.isCoverPhoto == this.isCoverPhoto &&
          other.capturedAt == this.capturedAt);
}

class PlaceMediaFilesCompanion extends UpdateCompanion<PlaceMediaFile> {
  final Value<String> id;
  final Value<String> placeId;
  final Value<String> localFilePath;
  final Value<String> thumbnailPath;
  final Value<int> fileSizeBytes;
  final Value<int> width;
  final Value<int> height;
  final Value<bool> isCoverPhoto;
  final Value<DateTime?> capturedAt;
  final Value<int> rowid;
  const PlaceMediaFilesCompanion({
    this.id = const Value.absent(),
    this.placeId = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.isCoverPhoto = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaceMediaFilesCompanion.insert({
    required String id,
    required String placeId,
    required String localFilePath,
    required String thumbnailPath,
    required int fileSizeBytes,
    required int width,
    required int height,
    this.isCoverPhoto = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       placeId = Value(placeId),
       localFilePath = Value(localFilePath),
       thumbnailPath = Value(thumbnailPath),
       fileSizeBytes = Value(fileSizeBytes),
       width = Value(width),
       height = Value(height);
  static Insertable<PlaceMediaFile> custom({
    Expression<String>? id,
    Expression<String>? placeId,
    Expression<String>? localFilePath,
    Expression<String>? thumbnailPath,
    Expression<int>? fileSizeBytes,
    Expression<int>? width,
    Expression<int>? height,
    Expression<bool>? isCoverPhoto,
    Expression<DateTime>? capturedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (placeId != null) 'place_id': placeId,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (isCoverPhoto != null) 'is_cover_photo': isCoverPhoto,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaceMediaFilesCompanion copyWith({
    Value<String>? id,
    Value<String>? placeId,
    Value<String>? localFilePath,
    Value<String>? thumbnailPath,
    Value<int>? fileSizeBytes,
    Value<int>? width,
    Value<int>? height,
    Value<bool>? isCoverPhoto,
    Value<DateTime?>? capturedAt,
    Value<int>? rowid,
  }) {
    return PlaceMediaFilesCompanion(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      localFilePath: localFilePath ?? this.localFilePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      isCoverPhoto: isCoverPhoto ?? this.isCoverPhoto,
      capturedAt: capturedAt ?? this.capturedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (placeId.present) {
      map['place_id'] = Variable<String>(placeId.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (isCoverPhoto.present) {
      map['is_cover_photo'] = Variable<bool>(isCoverPhoto.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaceMediaFilesCompanion(')
          ..write('id: $id, ')
          ..write('placeId: $placeId, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('isCoverPhoto: $isCoverPhoto, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RouteWaypointsTable extends RouteWaypoints
    with TableInfo<$RouteWaypointsTable, RouteWaypoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RouteWaypointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trip_albums (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _segmentOrderMeta = const VerificationMeta(
    'segmentOrder',
  );
  @override
  late final GeneratedColumn<int> segmentOrder = GeneratedColumn<int>(
    'segment_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encodedPolylineMeta = const VerificationMeta(
    'encodedPolyline',
  );
  @override
  late final GeneratedColumn<String> encodedPolyline = GeneratedColumn<String>(
    'encoded_polyline',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segmentDistanceMetersMeta =
      const VerificationMeta('segmentDistanceMeters');
  @override
  late final GeneratedColumn<double> segmentDistanceMeters =
      GeneratedColumn<double>(
        'segment_distance_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _estimatedDurationSecondsMeta =
      const VerificationMeta('estimatedDurationSeconds');
  @override
  late final GeneratedColumn<int> estimatedDurationSeconds =
      GeneratedColumn<int>(
        'estimated_duration_seconds',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    albumId,
    segmentOrder,
    encodedPolyline,
    segmentDistanceMeters,
    estimatedDurationSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'route_waypoints';
  @override
  VerificationContext validateIntegrity(
    Insertable<RouteWaypoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('segment_order')) {
      context.handle(
        _segmentOrderMeta,
        segmentOrder.isAcceptableOrUnknown(
          data['segment_order']!,
          _segmentOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_segmentOrderMeta);
    }
    if (data.containsKey('encoded_polyline')) {
      context.handle(
        _encodedPolylineMeta,
        encodedPolyline.isAcceptableOrUnknown(
          data['encoded_polyline']!,
          _encodedPolylineMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encodedPolylineMeta);
    }
    if (data.containsKey('segment_distance_meters')) {
      context.handle(
        _segmentDistanceMetersMeta,
        segmentDistanceMeters.isAcceptableOrUnknown(
          data['segment_distance_meters']!,
          _segmentDistanceMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_segmentDistanceMetersMeta);
    }
    if (data.containsKey('estimated_duration_seconds')) {
      context.handle(
        _estimatedDurationSecondsMeta,
        estimatedDurationSeconds.isAcceptableOrUnknown(
          data['estimated_duration_seconds']!,
          _estimatedDurationSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RouteWaypoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RouteWaypoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      )!,
      segmentOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segment_order'],
      )!,
      encodedPolyline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encoded_polyline'],
      )!,
      segmentDistanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}segment_distance_meters'],
      )!,
      estimatedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_duration_seconds'],
      ),
    );
  }

  @override
  $RouteWaypointsTable createAlias(String alias) {
    return $RouteWaypointsTable(attachedDatabase, alias);
  }
}

class RouteWaypoint extends DataClass implements Insertable<RouteWaypoint> {
  final int id;
  final String albumId;
  final int segmentOrder;
  final String encodedPolyline;
  final double segmentDistanceMeters;
  final int? estimatedDurationSeconds;
  const RouteWaypoint({
    required this.id,
    required this.albumId,
    required this.segmentOrder,
    required this.encodedPolyline,
    required this.segmentDistanceMeters,
    this.estimatedDurationSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['album_id'] = Variable<String>(albumId);
    map['segment_order'] = Variable<int>(segmentOrder);
    map['encoded_polyline'] = Variable<String>(encodedPolyline);
    map['segment_distance_meters'] = Variable<double>(segmentDistanceMeters);
    if (!nullToAbsent || estimatedDurationSeconds != null) {
      map['estimated_duration_seconds'] = Variable<int>(
        estimatedDurationSeconds,
      );
    }
    return map;
  }

  RouteWaypointsCompanion toCompanion(bool nullToAbsent) {
    return RouteWaypointsCompanion(
      id: Value(id),
      albumId: Value(albumId),
      segmentOrder: Value(segmentOrder),
      encodedPolyline: Value(encodedPolyline),
      segmentDistanceMeters: Value(segmentDistanceMeters),
      estimatedDurationSeconds: estimatedDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedDurationSeconds),
    );
  }

  factory RouteWaypoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RouteWaypoint(
      id: serializer.fromJson<int>(json['id']),
      albumId: serializer.fromJson<String>(json['albumId']),
      segmentOrder: serializer.fromJson<int>(json['segmentOrder']),
      encodedPolyline: serializer.fromJson<String>(json['encodedPolyline']),
      segmentDistanceMeters: serializer.fromJson<double>(
        json['segmentDistanceMeters'],
      ),
      estimatedDurationSeconds: serializer.fromJson<int?>(
        json['estimatedDurationSeconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'albumId': serializer.toJson<String>(albumId),
      'segmentOrder': serializer.toJson<int>(segmentOrder),
      'encodedPolyline': serializer.toJson<String>(encodedPolyline),
      'segmentDistanceMeters': serializer.toJson<double>(segmentDistanceMeters),
      'estimatedDurationSeconds': serializer.toJson<int?>(
        estimatedDurationSeconds,
      ),
    };
  }

  RouteWaypoint copyWith({
    int? id,
    String? albumId,
    int? segmentOrder,
    String? encodedPolyline,
    double? segmentDistanceMeters,
    Value<int?> estimatedDurationSeconds = const Value.absent(),
  }) => RouteWaypoint(
    id: id ?? this.id,
    albumId: albumId ?? this.albumId,
    segmentOrder: segmentOrder ?? this.segmentOrder,
    encodedPolyline: encodedPolyline ?? this.encodedPolyline,
    segmentDistanceMeters: segmentDistanceMeters ?? this.segmentDistanceMeters,
    estimatedDurationSeconds: estimatedDurationSeconds.present
        ? estimatedDurationSeconds.value
        : this.estimatedDurationSeconds,
  );
  RouteWaypoint copyWithCompanion(RouteWaypointsCompanion data) {
    return RouteWaypoint(
      id: data.id.present ? data.id.value : this.id,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      segmentOrder: data.segmentOrder.present
          ? data.segmentOrder.value
          : this.segmentOrder,
      encodedPolyline: data.encodedPolyline.present
          ? data.encodedPolyline.value
          : this.encodedPolyline,
      segmentDistanceMeters: data.segmentDistanceMeters.present
          ? data.segmentDistanceMeters.value
          : this.segmentDistanceMeters,
      estimatedDurationSeconds: data.estimatedDurationSeconds.present
          ? data.estimatedDurationSeconds.value
          : this.estimatedDurationSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RouteWaypoint(')
          ..write('id: $id, ')
          ..write('albumId: $albumId, ')
          ..write('segmentOrder: $segmentOrder, ')
          ..write('encodedPolyline: $encodedPolyline, ')
          ..write('segmentDistanceMeters: $segmentDistanceMeters, ')
          ..write('estimatedDurationSeconds: $estimatedDurationSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    albumId,
    segmentOrder,
    encodedPolyline,
    segmentDistanceMeters,
    estimatedDurationSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteWaypoint &&
          other.id == this.id &&
          other.albumId == this.albumId &&
          other.segmentOrder == this.segmentOrder &&
          other.encodedPolyline == this.encodedPolyline &&
          other.segmentDistanceMeters == this.segmentDistanceMeters &&
          other.estimatedDurationSeconds == this.estimatedDurationSeconds);
}

class RouteWaypointsCompanion extends UpdateCompanion<RouteWaypoint> {
  final Value<int> id;
  final Value<String> albumId;
  final Value<int> segmentOrder;
  final Value<String> encodedPolyline;
  final Value<double> segmentDistanceMeters;
  final Value<int?> estimatedDurationSeconds;
  const RouteWaypointsCompanion({
    this.id = const Value.absent(),
    this.albumId = const Value.absent(),
    this.segmentOrder = const Value.absent(),
    this.encodedPolyline = const Value.absent(),
    this.segmentDistanceMeters = const Value.absent(),
    this.estimatedDurationSeconds = const Value.absent(),
  });
  RouteWaypointsCompanion.insert({
    this.id = const Value.absent(),
    required String albumId,
    required int segmentOrder,
    required String encodedPolyline,
    required double segmentDistanceMeters,
    this.estimatedDurationSeconds = const Value.absent(),
  }) : albumId = Value(albumId),
       segmentOrder = Value(segmentOrder),
       encodedPolyline = Value(encodedPolyline),
       segmentDistanceMeters = Value(segmentDistanceMeters);
  static Insertable<RouteWaypoint> custom({
    Expression<int>? id,
    Expression<String>? albumId,
    Expression<int>? segmentOrder,
    Expression<String>? encodedPolyline,
    Expression<double>? segmentDistanceMeters,
    Expression<int>? estimatedDurationSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (albumId != null) 'album_id': albumId,
      if (segmentOrder != null) 'segment_order': segmentOrder,
      if (encodedPolyline != null) 'encoded_polyline': encodedPolyline,
      if (segmentDistanceMeters != null)
        'segment_distance_meters': segmentDistanceMeters,
      if (estimatedDurationSeconds != null)
        'estimated_duration_seconds': estimatedDurationSeconds,
    });
  }

  RouteWaypointsCompanion copyWith({
    Value<int>? id,
    Value<String>? albumId,
    Value<int>? segmentOrder,
    Value<String>? encodedPolyline,
    Value<double>? segmentDistanceMeters,
    Value<int?>? estimatedDurationSeconds,
  }) {
    return RouteWaypointsCompanion(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      segmentOrder: segmentOrder ?? this.segmentOrder,
      encodedPolyline: encodedPolyline ?? this.encodedPolyline,
      segmentDistanceMeters:
          segmentDistanceMeters ?? this.segmentDistanceMeters,
      estimatedDurationSeconds:
          estimatedDurationSeconds ?? this.estimatedDurationSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (segmentOrder.present) {
      map['segment_order'] = Variable<int>(segmentOrder.value);
    }
    if (encodedPolyline.present) {
      map['encoded_polyline'] = Variable<String>(encodedPolyline.value);
    }
    if (segmentDistanceMeters.present) {
      map['segment_distance_meters'] = Variable<double>(
        segmentDistanceMeters.value,
      );
    }
    if (estimatedDurationSeconds.present) {
      map['estimated_duration_seconds'] = Variable<int>(
        estimatedDurationSeconds.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RouteWaypointsCompanion(')
          ..write('id: $id, ')
          ..write('albumId: $albumId, ')
          ..write('segmentOrder: $segmentOrder, ')
          ..write('encodedPolyline: $encodedPolyline, ')
          ..write('segmentDistanceMeters: $segmentDistanceMeters, ')
          ..write('estimatedDurationSeconds: $estimatedDurationSeconds')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _handleMeta = const VerificationMeta('handle');
  @override
  late final GeneratedColumn<String> handle = GeneratedColumn<String>(
    'handle',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archetypeMeta = const VerificationMeta(
    'archetype',
  );
  @override
  late final GeneratedColumn<String> archetype = GeneratedColumn<String>(
    'archetype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Wayfarer'),
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitSystemMeta = const VerificationMeta(
    'unitSystem',
  );
  @override
  late final GeneratedColumn<String> unitSystem = GeneratedColumn<String>(
    'unit_system',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('metric'),
  );
  static const VerificationMeta _autoExifGpsEnabledMeta =
      const VerificationMeta('autoExifGpsEnabled');
  @override
  late final GeneratedColumn<bool> autoExifGpsEnabled = GeneratedColumn<bool>(
    'auto_exif_gps_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_exif_gps_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _vaultPathMeta = const VerificationMeta(
    'vaultPath',
  );
  @override
  late final GeneratedColumn<String> vaultPath = GeneratedColumn<String>(
    'vault_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('/sandbox/documents/vault_001.drift'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fullName,
    handle,
    avatarPath,
    archetype,
    bio,
    unitSystem,
    autoExifGpsEnabled,
    vaultPath,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('handle')) {
      context.handle(
        _handleMeta,
        handle.isAcceptableOrUnknown(data['handle']!, _handleMeta),
      );
    } else if (isInserting) {
      context.missing(_handleMeta);
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('archetype')) {
      context.handle(
        _archetypeMeta,
        archetype.isAcceptableOrUnknown(data['archetype']!, _archetypeMeta),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('unit_system')) {
      context.handle(
        _unitSystemMeta,
        unitSystem.isAcceptableOrUnknown(data['unit_system']!, _unitSystemMeta),
      );
    }
    if (data.containsKey('auto_exif_gps_enabled')) {
      context.handle(
        _autoExifGpsEnabledMeta,
        autoExifGpsEnabled.isAcceptableOrUnknown(
          data['auto_exif_gps_enabled']!,
          _autoExifGpsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('vault_path')) {
      context.handle(
        _vaultPathMeta,
        vaultPath.isAcceptableOrUnknown(data['vault_path']!, _vaultPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      handle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}handle'],
      )!,
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      archetype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archetype'],
      )!,
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      ),
      unitSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_system'],
      )!,
      autoExifGpsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_exif_gps_enabled'],
      )!,
      vaultPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vault_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String id;
  final String fullName;
  final String handle;
  final String? avatarPath;
  final String archetype;
  final String? bio;
  final String unitSystem;
  final bool autoExifGpsEnabled;
  final String vaultPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.handle,
    this.avatarPath,
    required this.archetype,
    this.bio,
    required this.unitSystem,
    required this.autoExifGpsEnabled,
    required this.vaultPath,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    map['handle'] = Variable<String>(handle);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    map['archetype'] = Variable<String>(archetype);
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    map['unit_system'] = Variable<String>(unitSystem);
    map['auto_exif_gps_enabled'] = Variable<bool>(autoExifGpsEnabled);
    map['vault_path'] = Variable<String>(vaultPath);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      fullName: Value(fullName),
      handle: Value(handle),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      archetype: Value(archetype),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      unitSystem: Value(unitSystem),
      autoExifGpsEnabled: Value(autoExifGpsEnabled),
      vaultPath: Value(vaultPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      handle: serializer.fromJson<String>(json['handle']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      archetype: serializer.fromJson<String>(json['archetype']),
      bio: serializer.fromJson<String?>(json['bio']),
      unitSystem: serializer.fromJson<String>(json['unitSystem']),
      autoExifGpsEnabled: serializer.fromJson<bool>(json['autoExifGpsEnabled']),
      vaultPath: serializer.fromJson<String>(json['vaultPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String>(fullName),
      'handle': serializer.toJson<String>(handle),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'archetype': serializer.toJson<String>(archetype),
      'bio': serializer.toJson<String?>(bio),
      'unitSystem': serializer.toJson<String>(unitSystem),
      'autoExifGpsEnabled': serializer.toJson<bool>(autoExifGpsEnabled),
      'vaultPath': serializer.toJson<String>(vaultPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? handle,
    Value<String?> avatarPath = const Value.absent(),
    String? archetype,
    Value<String?> bio = const Value.absent(),
    String? unitSystem,
    bool? autoExifGpsEnabled,
    String? vaultPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    handle: handle ?? this.handle,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    archetype: archetype ?? this.archetype,
    bio: bio.present ? bio.value : this.bio,
    unitSystem: unitSystem ?? this.unitSystem,
    autoExifGpsEnabled: autoExifGpsEnabled ?? this.autoExifGpsEnabled,
    vaultPath: vaultPath ?? this.vaultPath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      handle: data.handle.present ? data.handle.value : this.handle,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      archetype: data.archetype.present ? data.archetype.value : this.archetype,
      bio: data.bio.present ? data.bio.value : this.bio,
      unitSystem: data.unitSystem.present
          ? data.unitSystem.value
          : this.unitSystem,
      autoExifGpsEnabled: data.autoExifGpsEnabled.present
          ? data.autoExifGpsEnabled.value
          : this.autoExifGpsEnabled,
      vaultPath: data.vaultPath.present ? data.vaultPath.value : this.vaultPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('handle: $handle, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('archetype: $archetype, ')
          ..write('bio: $bio, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('autoExifGpsEnabled: $autoExifGpsEnabled, ')
          ..write('vaultPath: $vaultPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fullName,
    handle,
    avatarPath,
    archetype,
    bio,
    unitSystem,
    autoExifGpsEnabled,
    vaultPath,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.handle == this.handle &&
          other.avatarPath == this.avatarPath &&
          other.archetype == this.archetype &&
          other.bio == this.bio &&
          other.unitSystem == this.unitSystem &&
          other.autoExifGpsEnabled == this.autoExifGpsEnabled &&
          other.vaultPath == this.vaultPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<String> handle;
  final Value<String?> avatarPath;
  final Value<String> archetype;
  final Value<String?> bio;
  final Value<String> unitSystem;
  final Value<bool> autoExifGpsEnabled;
  final Value<String> vaultPath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.handle = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.archetype = const Value.absent(),
    this.bio = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.autoExifGpsEnabled = const Value.absent(),
    this.vaultPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String fullName,
    required String handle,
    this.avatarPath = const Value.absent(),
    this.archetype = const Value.absent(),
    this.bio = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.autoExifGpsEnabled = const Value.absent(),
    this.vaultPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fullName = Value(fullName),
       handle = Value(handle);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? handle,
    Expression<String>? avatarPath,
    Expression<String>? archetype,
    Expression<String>? bio,
    Expression<String>? unitSystem,
    Expression<bool>? autoExifGpsEnabled,
    Expression<String>? vaultPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (handle != null) 'handle': handle,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (archetype != null) 'archetype': archetype,
      if (bio != null) 'bio': bio,
      if (unitSystem != null) 'unit_system': unitSystem,
      if (autoExifGpsEnabled != null)
        'auto_exif_gps_enabled': autoExifGpsEnabled,
      if (vaultPath != null) 'vault_path': vaultPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? fullName,
    Value<String>? handle,
    Value<String?>? avatarPath,
    Value<String>? archetype,
    Value<String?>? bio,
    Value<String>? unitSystem,
    Value<bool>? autoExifGpsEnabled,
    Value<String>? vaultPath,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      handle: handle ?? this.handle,
      avatarPath: avatarPath ?? this.avatarPath,
      archetype: archetype ?? this.archetype,
      bio: bio ?? this.bio,
      unitSystem: unitSystem ?? this.unitSystem,
      autoExifGpsEnabled: autoExifGpsEnabled ?? this.autoExifGpsEnabled,
      vaultPath: vaultPath ?? this.vaultPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (handle.present) {
      map['handle'] = Variable<String>(handle.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (archetype.present) {
      map['archetype'] = Variable<String>(archetype.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (unitSystem.present) {
      map['unit_system'] = Variable<String>(unitSystem.value);
    }
    if (autoExifGpsEnabled.present) {
      map['auto_exif_gps_enabled'] = Variable<bool>(autoExifGpsEnabled.value);
    }
    if (vaultPath.present) {
      map['vault_path'] = Variable<String>(vaultPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('handle: $handle, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('archetype: $archetype, ')
          ..write('bio: $bio, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('autoExifGpsEnabled: $autoExifGpsEnabled, ')
          ..write('vaultPath: $vaultPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TripAlbumsTable tripAlbums = $TripAlbumsTable(this);
  late final $TripPlacesTable tripPlaces = $TripPlacesTable(this);
  late final $PlaceMediaFilesTable placeMediaFiles = $PlaceMediaFilesTable(
    this,
  );
  late final $RouteWaypointsTable routeWaypoints = $RouteWaypointsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final TripAlbumDao tripAlbumDao = TripAlbumDao(this as AppDatabase);
  late final TripPlaceDao tripPlaceDao = TripPlaceDao(this as AppDatabase);
  late final PlaceMediaDao placeMediaDao = PlaceMediaDao(this as AppDatabase);
  late final RouteWaypointDao routeWaypointDao = RouteWaypointDao(
    this as AppDatabase,
  );
  late final UserProfileDao userProfileDao = UserProfileDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tripAlbums,
    tripPlaces,
    placeMediaFiles,
    routeWaypoints,
    userProfiles,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trip_albums',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('trip_places', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trip_places',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('place_media_files', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trip_albums',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('route_waypoints', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TripAlbumsTableCreateCompanionBuilder =
    TripAlbumsCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<String?> coverImagePath,
      Value<String> status,
      Value<double> totalDistanceKm,
      Value<int> totalPlacesCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$TripAlbumsTableUpdateCompanionBuilder =
    TripAlbumsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<String?> coverImagePath,
      Value<String> status,
      Value<double> totalDistanceKm,
      Value<int> totalPlacesCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TripAlbumsTableReferences
    extends BaseReferences<_$AppDatabase, $TripAlbumsTable, TripAlbum> {
  $$TripAlbumsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TripPlacesTable, List<TripPlace>>
  _tripPlacesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripPlaces,
    aliasName: 'trip_albums__id__trip_places__album_id',
  );

  $$TripPlacesTableProcessedTableManager get tripPlacesRefs {
    final manager = $$TripPlacesTableTableManager(
      $_db,
      $_db.tripPlaces,
    ).filter((f) => f.albumId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripPlacesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RouteWaypointsTable, List<RouteWaypoint>>
  _routeWaypointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routeWaypoints,
    aliasName: 'trip_albums__id__route_waypoints__album_id',
  );

  $$RouteWaypointsTableProcessedTableManager get routeWaypointsRefs {
    final manager = $$RouteWaypointsTableTableManager(
      $_db,
      $_db.routeWaypoints,
    ).filter((f) => f.albumId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routeWaypointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripAlbumsTableFilterComposer
    extends Composer<_$AppDatabase, $TripAlbumsTable> {
  $$TripAlbumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalDistanceKm => $composableBuilder(
    column: $table.totalDistanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPlacesCount => $composableBuilder(
    column: $table.totalPlacesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tripPlacesRefs(
    Expression<bool> Function($$TripPlacesTableFilterComposer f) f,
  ) {
    final $$TripPlacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripPlaces,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripPlacesTableFilterComposer(
            $db: $db,
            $table: $db.tripPlaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> routeWaypointsRefs(
    Expression<bool> Function($$RouteWaypointsTableFilterComposer f) f,
  ) {
    final $$RouteWaypointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routeWaypoints,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RouteWaypointsTableFilterComposer(
            $db: $db,
            $table: $db.routeWaypoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripAlbumsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripAlbumsTable> {
  $$TripAlbumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalDistanceKm => $composableBuilder(
    column: $table.totalDistanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPlacesCount => $composableBuilder(
    column: $table.totalPlacesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripAlbumsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripAlbumsTable> {
  $$TripAlbumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get totalDistanceKm => $composableBuilder(
    column: $table.totalDistanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPlacesCount => $composableBuilder(
    column: $table.totalPlacesCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> tripPlacesRefs<T extends Object>(
    Expression<T> Function($$TripPlacesTableAnnotationComposer a) f,
  ) {
    final $$TripPlacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripPlaces,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripPlacesTableAnnotationComposer(
            $db: $db,
            $table: $db.tripPlaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> routeWaypointsRefs<T extends Object>(
    Expression<T> Function($$RouteWaypointsTableAnnotationComposer a) f,
  ) {
    final $$RouteWaypointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routeWaypoints,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RouteWaypointsTableAnnotationComposer(
            $db: $db,
            $table: $db.routeWaypoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripAlbumsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripAlbumsTable,
          TripAlbum,
          $$TripAlbumsTableFilterComposer,
          $$TripAlbumsTableOrderingComposer,
          $$TripAlbumsTableAnnotationComposer,
          $$TripAlbumsTableCreateCompanionBuilder,
          $$TripAlbumsTableUpdateCompanionBuilder,
          (TripAlbum, $$TripAlbumsTableReferences),
          TripAlbum,
          PrefetchHooks Function({bool tripPlacesRefs, bool routeWaypointsRefs})
        > {
  $$TripAlbumsTableTableManager(_$AppDatabase db, $TripAlbumsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripAlbumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripAlbumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripAlbumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> coverImagePath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> totalDistanceKm = const Value.absent(),
                Value<int> totalPlacesCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripAlbumsCompanion(
                id: id,
                title: title,
                description: description,
                startDate: startDate,
                endDate: endDate,
                coverImagePath: coverImagePath,
                status: status,
                totalDistanceKm: totalDistanceKm,
                totalPlacesCount: totalPlacesCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> coverImagePath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> totalDistanceKm = const Value.absent(),
                Value<int> totalPlacesCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripAlbumsCompanion.insert(
                id: id,
                title: title,
                description: description,
                startDate: startDate,
                endDate: endDate,
                coverImagePath: coverImagePath,
                status: status,
                totalDistanceKm: totalDistanceKm,
                totalPlacesCount: totalPlacesCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TripAlbumsTable, TripAlbum>(table),
                  $$TripAlbumsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tripPlacesRefs = false, routeWaypointsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tripPlacesRefs) db.tripPlaces,
                    if (routeWaypointsRefs) db.routeWaypoints,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tripPlacesRefs)
                        await $_getPrefetchedData<
                          TripAlbum,
                          $TripAlbumsTable,
                          TripPlace
                        >(
                          currentTable: table,
                          referencedTable: $$TripAlbumsTableReferences
                              ._tripPlacesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripAlbumsTableReferences(
                                db,
                                table,
                                p0,
                              ).tripPlacesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.albumId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (routeWaypointsRefs)
                        await $_getPrefetchedData<
                          TripAlbum,
                          $TripAlbumsTable,
                          RouteWaypoint
                        >(
                          currentTable: table,
                          referencedTable: $$TripAlbumsTableReferences
                              ._routeWaypointsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripAlbumsTableReferences(
                                db,
                                table,
                                p0,
                              ).routeWaypointsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.albumId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TripAlbumsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripAlbumsTable,
      TripAlbum,
      $$TripAlbumsTableFilterComposer,
      $$TripAlbumsTableOrderingComposer,
      $$TripAlbumsTableAnnotationComposer,
      $$TripAlbumsTableCreateCompanionBuilder,
      $$TripAlbumsTableUpdateCompanionBuilder,
      (TripAlbum, $$TripAlbumsTableReferences),
      TripAlbum,
      PrefetchHooks Function({bool tripPlacesRefs, bool routeWaypointsRefs})
    >;
typedef $$TripPlacesTableCreateCompanionBuilder =
    TripPlacesCompanion Function({
      required String id,
      required String albumId,
      required String name,
      Value<String?> notes,
      required double latitude,
      required double longitude,
      Value<double?> altitude,
      required DateTime visitedAt,
      required int visitOrder,
      Value<String?> weatherCondition,
      Value<double?> temperatureCelsius,
      Value<String> category,
      Value<String?> locationAddress,
      Value<String?> sensoryTags,
      Value<bool> isGpsFromExif,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$TripPlacesTableUpdateCompanionBuilder =
    TripPlacesCompanion Function({
      Value<String> id,
      Value<String> albumId,
      Value<String> name,
      Value<String?> notes,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> altitude,
      Value<DateTime> visitedAt,
      Value<int> visitOrder,
      Value<String?> weatherCondition,
      Value<double?> temperatureCelsius,
      Value<String> category,
      Value<String?> locationAddress,
      Value<String?> sensoryTags,
      Value<bool> isGpsFromExif,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TripPlacesTableReferences
    extends BaseReferences<_$AppDatabase, $TripPlacesTable, TripPlace> {
  $$TripPlacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripAlbumsTable _albumIdTable(_$AppDatabase db) =>
      db.tripAlbums.createAlias('trip_places__album_id__trip_albums__id');

  $$TripAlbumsTableProcessedTableManager get albumId {
    final $_column = $_itemColumn<String>('album_id')!;

    final manager = $$TripAlbumsTableTableManager(
      $_db,
      $_db.tripAlbums,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_albumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlaceMediaFilesTable, List<PlaceMediaFile>>
  _placeMediaFilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.placeMediaFiles,
    aliasName: 'trip_places__id__place_media_files__place_id',
  );

  $$PlaceMediaFilesTableProcessedTableManager get placeMediaFilesRefs {
    final manager = $$PlaceMediaFilesTableTableManager(
      $_db,
      $_db.placeMediaFiles,
    ).filter((f) => f.placeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _placeMediaFilesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripPlacesTableFilterComposer
    extends Composer<_$AppDatabase, $TripPlacesTable> {
  $$TripPlacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visitOrder => $composableBuilder(
    column: $table.visitOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherCondition => $composableBuilder(
    column: $table.weatherCondition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationAddress => $composableBuilder(
    column: $table.locationAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sensoryTags => $composableBuilder(
    column: $table.sensoryTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGpsFromExif => $composableBuilder(
    column: $table.isGpsFromExif,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TripAlbumsTableFilterComposer get albumId {
    final $$TripAlbumsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.tripAlbums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripAlbumsTableFilterComposer(
            $db: $db,
            $table: $db.tripAlbums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> placeMediaFilesRefs(
    Expression<bool> Function($$PlaceMediaFilesTableFilterComposer f) f,
  ) {
    final $$PlaceMediaFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.placeMediaFiles,
      getReferencedColumn: (t) => t.placeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaceMediaFilesTableFilterComposer(
            $db: $db,
            $table: $db.placeMediaFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripPlacesTableOrderingComposer
    extends Composer<_$AppDatabase, $TripPlacesTable> {
  $$TripPlacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visitOrder => $composableBuilder(
    column: $table.visitOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherCondition => $composableBuilder(
    column: $table.weatherCondition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationAddress => $composableBuilder(
    column: $table.locationAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sensoryTags => $composableBuilder(
    column: $table.sensoryTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGpsFromExif => $composableBuilder(
    column: $table.isGpsFromExif,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripAlbumsTableOrderingComposer get albumId {
    final $$TripAlbumsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.tripAlbums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripAlbumsTableOrderingComposer(
            $db: $db,
            $table: $db.tripAlbums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripPlacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripPlacesTable> {
  $$TripPlacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<DateTime> get visitedAt =>
      $composableBuilder(column: $table.visitedAt, builder: (column) => column);

  GeneratedColumn<int> get visitOrder => $composableBuilder(
    column: $table.visitOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weatherCondition => $composableBuilder(
    column: $table.weatherCondition,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get locationAddress => $composableBuilder(
    column: $table.locationAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sensoryTags => $composableBuilder(
    column: $table.sensoryTags,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isGpsFromExif => $composableBuilder(
    column: $table.isGpsFromExif,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TripAlbumsTableAnnotationComposer get albumId {
    final $$TripAlbumsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.tripAlbums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripAlbumsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripAlbums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> placeMediaFilesRefs<T extends Object>(
    Expression<T> Function($$PlaceMediaFilesTableAnnotationComposer a) f,
  ) {
    final $$PlaceMediaFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.placeMediaFiles,
      getReferencedColumn: (t) => t.placeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaceMediaFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.placeMediaFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripPlacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripPlacesTable,
          TripPlace,
          $$TripPlacesTableFilterComposer,
          $$TripPlacesTableOrderingComposer,
          $$TripPlacesTableAnnotationComposer,
          $$TripPlacesTableCreateCompanionBuilder,
          $$TripPlacesTableUpdateCompanionBuilder,
          (TripPlace, $$TripPlacesTableReferences),
          TripPlace,
          PrefetchHooks Function({bool albumId, bool placeMediaFilesRefs})
        > {
  $$TripPlacesTableTableManager(_$AppDatabase db, $TripPlacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripPlacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripPlacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripPlacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> albumId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<DateTime> visitedAt = const Value.absent(),
                Value<int> visitOrder = const Value.absent(),
                Value<String?> weatherCondition = const Value.absent(),
                Value<double?> temperatureCelsius = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> locationAddress = const Value.absent(),
                Value<String?> sensoryTags = const Value.absent(),
                Value<bool> isGpsFromExif = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripPlacesCompanion(
                id: id,
                albumId: albumId,
                name: name,
                notes: notes,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                visitedAt: visitedAt,
                visitOrder: visitOrder,
                weatherCondition: weatherCondition,
                temperatureCelsius: temperatureCelsius,
                category: category,
                locationAddress: locationAddress,
                sensoryTags: sensoryTags,
                isGpsFromExif: isGpsFromExif,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String albumId,
                required String name,
                Value<String?> notes = const Value.absent(),
                required double latitude,
                required double longitude,
                Value<double?> altitude = const Value.absent(),
                required DateTime visitedAt,
                required int visitOrder,
                Value<String?> weatherCondition = const Value.absent(),
                Value<double?> temperatureCelsius = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> locationAddress = const Value.absent(),
                Value<String?> sensoryTags = const Value.absent(),
                Value<bool> isGpsFromExif = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripPlacesCompanion.insert(
                id: id,
                albumId: albumId,
                name: name,
                notes: notes,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                visitedAt: visitedAt,
                visitOrder: visitOrder,
                weatherCondition: weatherCondition,
                temperatureCelsius: temperatureCelsius,
                category: category,
                locationAddress: locationAddress,
                sensoryTags: sensoryTags,
                isGpsFromExif: isGpsFromExif,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TripPlacesTable, TripPlace>(table),
                  $$TripPlacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({albumId = false, placeMediaFilesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (placeMediaFilesRefs) db.placeMediaFiles,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (albumId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.albumId,
                                    referencedTable: $$TripPlacesTableReferences
                                        ._albumIdTable(db),
                                    referencedColumn:
                                        $$TripPlacesTableReferences
                                            ._albumIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (placeMediaFilesRefs)
                        await $_getPrefetchedData<
                          TripPlace,
                          $TripPlacesTable,
                          PlaceMediaFile
                        >(
                          currentTable: table,
                          referencedTable: $$TripPlacesTableReferences
                              ._placeMediaFilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripPlacesTableReferences(
                                db,
                                table,
                                p0,
                              ).placeMediaFilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.placeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TripPlacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripPlacesTable,
      TripPlace,
      $$TripPlacesTableFilterComposer,
      $$TripPlacesTableOrderingComposer,
      $$TripPlacesTableAnnotationComposer,
      $$TripPlacesTableCreateCompanionBuilder,
      $$TripPlacesTableUpdateCompanionBuilder,
      (TripPlace, $$TripPlacesTableReferences),
      TripPlace,
      PrefetchHooks Function({bool albumId, bool placeMediaFilesRefs})
    >;
typedef $$PlaceMediaFilesTableCreateCompanionBuilder =
    PlaceMediaFilesCompanion Function({
      required String id,
      required String placeId,
      required String localFilePath,
      required String thumbnailPath,
      required int fileSizeBytes,
      required int width,
      required int height,
      Value<bool> isCoverPhoto,
      Value<DateTime?> capturedAt,
      Value<int> rowid,
    });
typedef $$PlaceMediaFilesTableUpdateCompanionBuilder =
    PlaceMediaFilesCompanion Function({
      Value<String> id,
      Value<String> placeId,
      Value<String> localFilePath,
      Value<String> thumbnailPath,
      Value<int> fileSizeBytes,
      Value<int> width,
      Value<int> height,
      Value<bool> isCoverPhoto,
      Value<DateTime?> capturedAt,
      Value<int> rowid,
    });

final class $$PlaceMediaFilesTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlaceMediaFilesTable, PlaceMediaFile> {
  $$PlaceMediaFilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripPlacesTable _placeIdTable(_$AppDatabase db) =>
      db.tripPlaces.createAlias('place_media_files__place_id__trip_places__id');

  $$TripPlacesTableProcessedTableManager get placeId {
    final $_column = $_itemColumn<String>('place_id')!;

    final manager = $$TripPlacesTableTableManager(
      $_db,
      $_db.tripPlaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_placeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaceMediaFilesTableFilterComposer
    extends Composer<_$AppDatabase, $PlaceMediaFilesTable> {
  $$PlaceMediaFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCoverPhoto => $composableBuilder(
    column: $table.isCoverPhoto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TripPlacesTableFilterComposer get placeId {
    final $$TripPlacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.tripPlaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripPlacesTableFilterComposer(
            $db: $db,
            $table: $db.tripPlaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaceMediaFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaceMediaFilesTable> {
  $$PlaceMediaFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCoverPhoto => $composableBuilder(
    column: $table.isCoverPhoto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripPlacesTableOrderingComposer get placeId {
    final $$TripPlacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.tripPlaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripPlacesTableOrderingComposer(
            $db: $db,
            $table: $db.tripPlaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaceMediaFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaceMediaFilesTable> {
  $$PlaceMediaFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<bool> get isCoverPhoto => $composableBuilder(
    column: $table.isCoverPhoto,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  $$TripPlacesTableAnnotationComposer get placeId {
    final $$TripPlacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.placeId,
      referencedTable: $db.tripPlaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripPlacesTableAnnotationComposer(
            $db: $db,
            $table: $db.tripPlaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaceMediaFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaceMediaFilesTable,
          PlaceMediaFile,
          $$PlaceMediaFilesTableFilterComposer,
          $$PlaceMediaFilesTableOrderingComposer,
          $$PlaceMediaFilesTableAnnotationComposer,
          $$PlaceMediaFilesTableCreateCompanionBuilder,
          $$PlaceMediaFilesTableUpdateCompanionBuilder,
          (PlaceMediaFile, $$PlaceMediaFilesTableReferences),
          PlaceMediaFile,
          PrefetchHooks Function({bool placeId})
        > {
  $$PlaceMediaFilesTableTableManager(
    _$AppDatabase db,
    $PlaceMediaFilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaceMediaFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaceMediaFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaceMediaFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> placeId = const Value.absent(),
                Value<String> localFilePath = const Value.absent(),
                Value<String> thumbnailPath = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<bool> isCoverPhoto = const Value.absent(),
                Value<DateTime?> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaceMediaFilesCompanion(
                id: id,
                placeId: placeId,
                localFilePath: localFilePath,
                thumbnailPath: thumbnailPath,
                fileSizeBytes: fileSizeBytes,
                width: width,
                height: height,
                isCoverPhoto: isCoverPhoto,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String placeId,
                required String localFilePath,
                required String thumbnailPath,
                required int fileSizeBytes,
                required int width,
                required int height,
                Value<bool> isCoverPhoto = const Value.absent(),
                Value<DateTime?> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaceMediaFilesCompanion.insert(
                id: id,
                placeId: placeId,
                localFilePath: localFilePath,
                thumbnailPath: thumbnailPath,
                fileSizeBytes: fileSizeBytes,
                width: width,
                height: height,
                isCoverPhoto: isCoverPhoto,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaceMediaFilesTable, PlaceMediaFile>(table),
                  $$PlaceMediaFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({placeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (placeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.placeId,
                                referencedTable:
                                    $$PlaceMediaFilesTableReferences
                                        ._placeIdTable(db),
                                referencedColumn:
                                    $$PlaceMediaFilesTableReferences
                                        ._placeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaceMediaFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaceMediaFilesTable,
      PlaceMediaFile,
      $$PlaceMediaFilesTableFilterComposer,
      $$PlaceMediaFilesTableOrderingComposer,
      $$PlaceMediaFilesTableAnnotationComposer,
      $$PlaceMediaFilesTableCreateCompanionBuilder,
      $$PlaceMediaFilesTableUpdateCompanionBuilder,
      (PlaceMediaFile, $$PlaceMediaFilesTableReferences),
      PlaceMediaFile,
      PrefetchHooks Function({bool placeId})
    >;
typedef $$RouteWaypointsTableCreateCompanionBuilder =
    RouteWaypointsCompanion Function({
      Value<int> id,
      required String albumId,
      required int segmentOrder,
      required String encodedPolyline,
      required double segmentDistanceMeters,
      Value<int?> estimatedDurationSeconds,
    });
typedef $$RouteWaypointsTableUpdateCompanionBuilder =
    RouteWaypointsCompanion Function({
      Value<int> id,
      Value<String> albumId,
      Value<int> segmentOrder,
      Value<String> encodedPolyline,
      Value<double> segmentDistanceMeters,
      Value<int?> estimatedDurationSeconds,
    });

final class $$RouteWaypointsTableReferences
    extends BaseReferences<_$AppDatabase, $RouteWaypointsTable, RouteWaypoint> {
  $$RouteWaypointsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripAlbumsTable _albumIdTable(_$AppDatabase db) =>
      db.tripAlbums.createAlias('route_waypoints__album_id__trip_albums__id');

  $$TripAlbumsTableProcessedTableManager get albumId {
    final $_column = $_itemColumn<String>('album_id')!;

    final manager = $$TripAlbumsTableTableManager(
      $_db,
      $_db.tripAlbums,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_albumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RouteWaypointsTableFilterComposer
    extends Composer<_$AppDatabase, $RouteWaypointsTable> {
  $$RouteWaypointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get segmentOrder => $composableBuilder(
    column: $table.segmentOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encodedPolyline => $composableBuilder(
    column: $table.encodedPolyline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get segmentDistanceMeters => $composableBuilder(
    column: $table.segmentDistanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedDurationSeconds => $composableBuilder(
    column: $table.estimatedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  $$TripAlbumsTableFilterComposer get albumId {
    final $$TripAlbumsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.tripAlbums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripAlbumsTableFilterComposer(
            $db: $db,
            $table: $db.tripAlbums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RouteWaypointsTableOrderingComposer
    extends Composer<_$AppDatabase, $RouteWaypointsTable> {
  $$RouteWaypointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get segmentOrder => $composableBuilder(
    column: $table.segmentOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encodedPolyline => $composableBuilder(
    column: $table.encodedPolyline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get segmentDistanceMeters => $composableBuilder(
    column: $table.segmentDistanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedDurationSeconds => $composableBuilder(
    column: $table.estimatedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripAlbumsTableOrderingComposer get albumId {
    final $$TripAlbumsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.tripAlbums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripAlbumsTableOrderingComposer(
            $db: $db,
            $table: $db.tripAlbums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RouteWaypointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RouteWaypointsTable> {
  $$RouteWaypointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get segmentOrder => $composableBuilder(
    column: $table.segmentOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encodedPolyline => $composableBuilder(
    column: $table.encodedPolyline,
    builder: (column) => column,
  );

  GeneratedColumn<double> get segmentDistanceMeters => $composableBuilder(
    column: $table.segmentDistanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedDurationSeconds => $composableBuilder(
    column: $table.estimatedDurationSeconds,
    builder: (column) => column,
  );

  $$TripAlbumsTableAnnotationComposer get albumId {
    final $$TripAlbumsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.tripAlbums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripAlbumsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripAlbums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RouteWaypointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RouteWaypointsTable,
          RouteWaypoint,
          $$RouteWaypointsTableFilterComposer,
          $$RouteWaypointsTableOrderingComposer,
          $$RouteWaypointsTableAnnotationComposer,
          $$RouteWaypointsTableCreateCompanionBuilder,
          $$RouteWaypointsTableUpdateCompanionBuilder,
          (RouteWaypoint, $$RouteWaypointsTableReferences),
          RouteWaypoint,
          PrefetchHooks Function({bool albumId})
        > {
  $$RouteWaypointsTableTableManager(
    _$AppDatabase db,
    $RouteWaypointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RouteWaypointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RouteWaypointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RouteWaypointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> albumId = const Value.absent(),
                Value<int> segmentOrder = const Value.absent(),
                Value<String> encodedPolyline = const Value.absent(),
                Value<double> segmentDistanceMeters = const Value.absent(),
                Value<int?> estimatedDurationSeconds = const Value.absent(),
              }) => RouteWaypointsCompanion(
                id: id,
                albumId: albumId,
                segmentOrder: segmentOrder,
                encodedPolyline: encodedPolyline,
                segmentDistanceMeters: segmentDistanceMeters,
                estimatedDurationSeconds: estimatedDurationSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String albumId,
                required int segmentOrder,
                required String encodedPolyline,
                required double segmentDistanceMeters,
                Value<int?> estimatedDurationSeconds = const Value.absent(),
              }) => RouteWaypointsCompanion.insert(
                id: id,
                albumId: albumId,
                segmentOrder: segmentOrder,
                encodedPolyline: encodedPolyline,
                segmentDistanceMeters: segmentDistanceMeters,
                estimatedDurationSeconds: estimatedDurationSeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RouteWaypointsTable, RouteWaypoint>(table),
                  $$RouteWaypointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({albumId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (albumId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.albumId,
                                referencedTable: $$RouteWaypointsTableReferences
                                    ._albumIdTable(db),
                                referencedColumn:
                                    $$RouteWaypointsTableReferences
                                        ._albumIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RouteWaypointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RouteWaypointsTable,
      RouteWaypoint,
      $$RouteWaypointsTableFilterComposer,
      $$RouteWaypointsTableOrderingComposer,
      $$RouteWaypointsTableAnnotationComposer,
      $$RouteWaypointsTableCreateCompanionBuilder,
      $$RouteWaypointsTableUpdateCompanionBuilder,
      (RouteWaypoint, $$RouteWaypointsTableReferences),
      RouteWaypoint,
      PrefetchHooks Function({bool albumId})
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      required String fullName,
      required String handle,
      Value<String?> avatarPath,
      Value<String> archetype,
      Value<String?> bio,
      Value<String> unitSystem,
      Value<bool> autoExifGpsEnabled,
      Value<String> vaultPath,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String> fullName,
      Value<String> handle,
      Value<String?> avatarPath,
      Value<String> archetype,
      Value<String?> bio,
      Value<String> unitSystem,
      Value<bool> autoExifGpsEnabled,
      Value<String> vaultPath,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handle => $composableBuilder(
    column: $table.handle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archetype => $composableBuilder(
    column: $table.archetype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoExifGpsEnabled => $composableBuilder(
    column: $table.autoExifGpsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vaultPath => $composableBuilder(
    column: $table.vaultPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handle => $composableBuilder(
    column: $table.handle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archetype => $composableBuilder(
    column: $table.archetype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoExifGpsEnabled => $composableBuilder(
    column: $table.autoExifGpsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vaultPath => $composableBuilder(
    column: $table.vaultPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get handle =>
      $composableBuilder(column: $table.handle, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get archetype =>
      $composableBuilder(column: $table.archetype, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoExifGpsEnabled => $composableBuilder(
    column: $table.autoExifGpsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vaultPath =>
      $composableBuilder(column: $table.vaultPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> handle = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<String> archetype = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String> unitSystem = const Value.absent(),
                Value<bool> autoExifGpsEnabled = const Value.absent(),
                Value<String> vaultPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                fullName: fullName,
                handle: handle,
                avatarPath: avatarPath,
                archetype: archetype,
                bio: bio,
                unitSystem: unitSystem,
                autoExifGpsEnabled: autoExifGpsEnabled,
                vaultPath: vaultPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fullName,
                required String handle,
                Value<String?> avatarPath = const Value.absent(),
                Value<String> archetype = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String> unitSystem = const Value.absent(),
                Value<bool> autoExifGpsEnabled = const Value.absent(),
                Value<String> vaultPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                fullName: fullName,
                handle: handle,
                avatarPath: avatarPath,
                archetype: archetype,
                bio: bio,
                unitSystem: unitSystem,
                autoExifGpsEnabled: autoExifGpsEnabled,
                vaultPath: vaultPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserProfilesTable, UserProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserProfilesTable,
                    UserProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TripAlbumsTableTableManager get tripAlbums =>
      $$TripAlbumsTableTableManager(_db, _db.tripAlbums);
  $$TripPlacesTableTableManager get tripPlaces =>
      $$TripPlacesTableTableManager(_db, _db.tripPlaces);
  $$PlaceMediaFilesTableTableManager get placeMediaFiles =>
      $$PlaceMediaFilesTableTableManager(_db, _db.placeMediaFiles);
  $$RouteWaypointsTableTableManager get routeWaypoints =>
      $$RouteWaypointsTableTableManager(_db, _db.routeWaypoints);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
}
