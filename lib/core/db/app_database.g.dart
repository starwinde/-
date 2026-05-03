// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, Schedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isTodoMeta = const VerificationMeta('isTodo');
  @override
  late final GeneratedColumn<bool> isTodo = GeneratedColumn<bool>(
    'is_todo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_todo" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allowDisruptionMeta = const VerificationMeta(
    'allowDisruption',
  );
  @override
  late final GeneratedColumn<bool> allowDisruption = GeneratedColumn<bool>(
    'allow_disruption',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow_disruption" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _disruptionIntensityMeta =
      const VerificationMeta('disruptionIntensity');
  @override
  late final GeneratedColumn<int> disruptionIntensity = GeneratedColumn<int>(
    'disruption_intensity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
    remoteId,
    userId,
    title,
    category,
    tags,
    startTime,
    endTime,
    isTodo,
    isCompleted,
    deletedAt,
    allowDisruption,
    disruptionIntensity,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<Schedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('is_todo')) {
      context.handle(
        _isTodoMeta,
        isTodo.isAcceptableOrUnknown(data['is_todo']!, _isTodoMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('allow_disruption')) {
      context.handle(
        _allowDisruptionMeta,
        allowDisruption.isAcceptableOrUnknown(
          data['allow_disruption']!,
          _allowDisruptionMeta,
        ),
      );
    }
    if (data.containsKey('disruption_intensity')) {
      context.handle(
        _disruptionIntensityMeta,
        disruptionIntensity.isAcceptableOrUnknown(
          data['disruption_intensity']!,
          _disruptionIntensityMeta,
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
  Schedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Schedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      isTodo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_todo'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      allowDisruption: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_disruption'],
      )!,
      disruptionIntensity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disruption_intensity'],
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
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }
}

class Schedule extends DataClass implements Insertable<Schedule> {
  final int id;
  final String? remoteId;
  final String userId;
  final String title;
  final String category;
  final String tags;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isTodo;
  final bool isCompleted;
  final DateTime? deletedAt;
  final bool allowDisruption;
  final int disruptionIntensity;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Schedule({
    required this.id,
    this.remoteId,
    required this.userId,
    required this.title,
    required this.category,
    required this.tags,
    this.startTime,
    this.endTime,
    required this.isTodo,
    required this.isCompleted,
    this.deletedAt,
    required this.allowDisruption,
    required this.disruptionIntensity,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['tags'] = Variable<String>(tags);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<DateTime>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['is_todo'] = Variable<bool>(isTodo);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['allow_disruption'] = Variable<bool>(allowDisruption);
    map['disruption_intensity'] = Variable<int>(disruptionIntensity);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      userId: Value(userId),
      title: Value(title),
      category: Value(category),
      tags: Value(tags),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      isTodo: Value(isTodo),
      isCompleted: Value(isCompleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      allowDisruption: Value(allowDisruption),
      disruptionIntensity: Value(disruptionIntensity),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Schedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Schedule(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      tags: serializer.fromJson<String>(json['tags']),
      startTime: serializer.fromJson<DateTime?>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      isTodo: serializer.fromJson<bool>(json['isTodo']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      allowDisruption: serializer.fromJson<bool>(json['allowDisruption']),
      disruptionIntensity: serializer.fromJson<int>(
        json['disruptionIntensity'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'tags': serializer.toJson<String>(tags),
      'startTime': serializer.toJson<DateTime?>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'isTodo': serializer.toJson<bool>(isTodo),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'allowDisruption': serializer.toJson<bool>(allowDisruption),
      'disruptionIntensity': serializer.toJson<int>(disruptionIntensity),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Schedule copyWith({
    int? id,
    Value<String?> remoteId = const Value.absent(),
    String? userId,
    String? title,
    String? category,
    String? tags,
    Value<DateTime?> startTime = const Value.absent(),
    Value<DateTime?> endTime = const Value.absent(),
    bool? isTodo,
    bool? isCompleted,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? allowDisruption,
    int? disruptionIntensity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Schedule(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    category: category ?? this.category,
    tags: tags ?? this.tags,
    startTime: startTime.present ? startTime.value : this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    isTodo: isTodo ?? this.isTodo,
    isCompleted: isCompleted ?? this.isCompleted,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    allowDisruption: allowDisruption ?? this.allowDisruption,
    disruptionIntensity: disruptionIntensity ?? this.disruptionIntensity,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Schedule copyWithCompanion(SchedulesCompanion data) {
    return Schedule(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      tags: data.tags.present ? data.tags.value : this.tags,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      isTodo: data.isTodo.present ? data.isTodo.value : this.isTodo,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      allowDisruption: data.allowDisruption.present
          ? data.allowDisruption.value
          : this.allowDisruption,
      disruptionIntensity: data.disruptionIntensity.present
          ? data.disruptionIntensity.value
          : this.disruptionIntensity,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Schedule(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('tags: $tags, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('isTodo: $isTodo, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('allowDisruption: $allowDisruption, ')
          ..write('disruptionIntensity: $disruptionIntensity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    userId,
    title,
    category,
    tags,
    startTime,
    endTime,
    isTodo,
    isCompleted,
    deletedAt,
    allowDisruption,
    disruptionIntensity,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Schedule &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.category == this.category &&
          other.tags == this.tags &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.isTodo == this.isTodo &&
          other.isCompleted == this.isCompleted &&
          other.deletedAt == this.deletedAt &&
          other.allowDisruption == this.allowDisruption &&
          other.disruptionIntensity == this.disruptionIntensity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SchedulesCompanion extends UpdateCompanion<Schedule> {
  final Value<int> id;
  final Value<String?> remoteId;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> category;
  final Value<String> tags;
  final Value<DateTime?> startTime;
  final Value<DateTime?> endTime;
  final Value<bool> isTodo;
  final Value<bool> isCompleted;
  final Value<DateTime?> deletedAt;
  final Value<bool> allowDisruption;
  final Value<int> disruptionIntensity;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.tags = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.isTodo = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.allowDisruption = const Value.absent(),
    this.disruptionIntensity = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SchedulesCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    required String userId,
    required String title,
    required String category,
    this.tags = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.isTodo = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.allowDisruption = const Value.absent(),
    this.disruptionIntensity = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : userId = Value(userId),
       title = Value(title),
       category = Value(category);
  static Insertable<Schedule> custom({
    Expression<int>? id,
    Expression<String>? remoteId,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? tags,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<bool>? isTodo,
    Expression<bool>? isCompleted,
    Expression<DateTime>? deletedAt,
    Expression<bool>? allowDisruption,
    Expression<int>? disruptionIntensity,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (isTodo != null) 'is_todo': isTodo,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (allowDisruption != null) 'allow_disruption': allowDisruption,
      if (disruptionIntensity != null)
        'disruption_intensity': disruptionIntensity,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SchedulesCompanion copyWith({
    Value<int>? id,
    Value<String?>? remoteId,
    Value<String>? userId,
    Value<String>? title,
    Value<String>? category,
    Value<String>? tags,
    Value<DateTime?>? startTime,
    Value<DateTime?>? endTime,
    Value<bool>? isTodo,
    Value<bool>? isCompleted,
    Value<DateTime?>? deletedAt,
    Value<bool>? allowDisruption,
    Value<int>? disruptionIntensity,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SchedulesCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isTodo: isTodo ?? this.isTodo,
      isCompleted: isCompleted ?? this.isCompleted,
      deletedAt: deletedAt ?? this.deletedAt,
      allowDisruption: allowDisruption ?? this.allowDisruption,
      disruptionIntensity: disruptionIntensity ?? this.disruptionIntensity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (isTodo.present) {
      map['is_todo'] = Variable<bool>(isTodo.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (allowDisruption.present) {
      map['allow_disruption'] = Variable<bool>(allowDisruption.value);
    }
    if (disruptionIntensity.present) {
      map['disruption_intensity'] = Variable<int>(disruptionIntensity.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('tags: $tags, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('isTodo: $isTodo, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('allowDisruption: $allowDisruption, ')
          ..write('disruptionIntensity: $disruptionIntensity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PetsTable extends Pets with TableInfo<$PetsTable, Pet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hpMeta = const VerificationMeta('hp');
  @override
  late final GeneratedColumn<int> hp = GeneratedColumn<int>(
    'hp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _isAliveMeta = const VerificationMeta(
    'isAlive',
  );
  @override
  late final GeneratedColumn<bool> isAlive = GeneratedColumn<bool>(
    'is_alive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_alive" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  static const VerificationMeta _diedAtMeta = const VerificationMeta('diedAt');
  @override
  late final GeneratedColumn<DateTime> diedAt = GeneratedColumn<DateTime>(
    'died_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deathCauseMeta = const VerificationMeta(
    'deathCause',
  );
  @override
  late final GeneratedColumn<String> deathCause = GeneratedColumn<String>(
    'death_cause',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    userId,
    species,
    name,
    level,
    xp,
    hp,
    isAlive,
    createdAt,
    diedAt,
    deathCause,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('hp')) {
      context.handle(_hpMeta, hp.isAcceptableOrUnknown(data['hp']!, _hpMeta));
    }
    if (data.containsKey('is_alive')) {
      context.handle(
        _isAliveMeta,
        isAlive.isAcceptableOrUnknown(data['is_alive']!, _isAliveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('died_at')) {
      context.handle(
        _diedAtMeta,
        diedAt.isAcceptableOrUnknown(data['died_at']!, _diedAtMeta),
      );
    }
    if (data.containsKey('death_cause')) {
      context.handle(
        _deathCauseMeta,
        deathCause.isAcceptableOrUnknown(data['death_cause']!, _deathCauseMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      hp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hp'],
      )!,
      isAlive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_alive'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      diedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}died_at'],
      ),
      deathCause: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}death_cause'],
      ),
    );
  }

  @override
  $PetsTable createAlias(String alias) {
    return $PetsTable(attachedDatabase, alias);
  }
}

class Pet extends DataClass implements Insertable<Pet> {
  final int id;
  final String? remoteId;
  final String userId;
  final String species;
  final String name;
  final int level;
  final int xp;
  final int hp;
  final bool isAlive;
  final DateTime createdAt;
  final DateTime? diedAt;
  final String? deathCause;
  const Pet({
    required this.id,
    this.remoteId,
    required this.userId,
    required this.species,
    required this.name,
    required this.level,
    required this.xp,
    required this.hp,
    required this.isAlive,
    required this.createdAt,
    this.diedAt,
    this.deathCause,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['user_id'] = Variable<String>(userId);
    map['species'] = Variable<String>(species);
    map['name'] = Variable<String>(name);
    map['level'] = Variable<int>(level);
    map['xp'] = Variable<int>(xp);
    map['hp'] = Variable<int>(hp);
    map['is_alive'] = Variable<bool>(isAlive);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || diedAt != null) {
      map['died_at'] = Variable<DateTime>(diedAt);
    }
    if (!nullToAbsent || deathCause != null) {
      map['death_cause'] = Variable<String>(deathCause);
    }
    return map;
  }

  PetsCompanion toCompanion(bool nullToAbsent) {
    return PetsCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      userId: Value(userId),
      species: Value(species),
      name: Value(name),
      level: Value(level),
      xp: Value(xp),
      hp: Value(hp),
      isAlive: Value(isAlive),
      createdAt: Value(createdAt),
      diedAt: diedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(diedAt),
      deathCause: deathCause == null && nullToAbsent
          ? const Value.absent()
          : Value(deathCause),
    );
  }

  factory Pet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pet(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      userId: serializer.fromJson<String>(json['userId']),
      species: serializer.fromJson<String>(json['species']),
      name: serializer.fromJson<String>(json['name']),
      level: serializer.fromJson<int>(json['level']),
      xp: serializer.fromJson<int>(json['xp']),
      hp: serializer.fromJson<int>(json['hp']),
      isAlive: serializer.fromJson<bool>(json['isAlive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      diedAt: serializer.fromJson<DateTime?>(json['diedAt']),
      deathCause: serializer.fromJson<String?>(json['deathCause']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'userId': serializer.toJson<String>(userId),
      'species': serializer.toJson<String>(species),
      'name': serializer.toJson<String>(name),
      'level': serializer.toJson<int>(level),
      'xp': serializer.toJson<int>(xp),
      'hp': serializer.toJson<int>(hp),
      'isAlive': serializer.toJson<bool>(isAlive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'diedAt': serializer.toJson<DateTime?>(diedAt),
      'deathCause': serializer.toJson<String?>(deathCause),
    };
  }

  Pet copyWith({
    int? id,
    Value<String?> remoteId = const Value.absent(),
    String? userId,
    String? species,
    String? name,
    int? level,
    int? xp,
    int? hp,
    bool? isAlive,
    DateTime? createdAt,
    Value<DateTime?> diedAt = const Value.absent(),
    Value<String?> deathCause = const Value.absent(),
  }) => Pet(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    userId: userId ?? this.userId,
    species: species ?? this.species,
    name: name ?? this.name,
    level: level ?? this.level,
    xp: xp ?? this.xp,
    hp: hp ?? this.hp,
    isAlive: isAlive ?? this.isAlive,
    createdAt: createdAt ?? this.createdAt,
    diedAt: diedAt.present ? diedAt.value : this.diedAt,
    deathCause: deathCause.present ? deathCause.value : this.deathCause,
  );
  Pet copyWithCompanion(PetsCompanion data) {
    return Pet(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      userId: data.userId.present ? data.userId.value : this.userId,
      species: data.species.present ? data.species.value : this.species,
      name: data.name.present ? data.name.value : this.name,
      level: data.level.present ? data.level.value : this.level,
      xp: data.xp.present ? data.xp.value : this.xp,
      hp: data.hp.present ? data.hp.value : this.hp,
      isAlive: data.isAlive.present ? data.isAlive.value : this.isAlive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      diedAt: data.diedAt.present ? data.diedAt.value : this.diedAt,
      deathCause: data.deathCause.present
          ? data.deathCause.value
          : this.deathCause,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pet(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('userId: $userId, ')
          ..write('species: $species, ')
          ..write('name: $name, ')
          ..write('level: $level, ')
          ..write('xp: $xp, ')
          ..write('hp: $hp, ')
          ..write('isAlive: $isAlive, ')
          ..write('createdAt: $createdAt, ')
          ..write('diedAt: $diedAt, ')
          ..write('deathCause: $deathCause')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    userId,
    species,
    name,
    level,
    xp,
    hp,
    isAlive,
    createdAt,
    diedAt,
    deathCause,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pet &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.userId == this.userId &&
          other.species == this.species &&
          other.name == this.name &&
          other.level == this.level &&
          other.xp == this.xp &&
          other.hp == this.hp &&
          other.isAlive == this.isAlive &&
          other.createdAt == this.createdAt &&
          other.diedAt == this.diedAt &&
          other.deathCause == this.deathCause);
}

class PetsCompanion extends UpdateCompanion<Pet> {
  final Value<int> id;
  final Value<String?> remoteId;
  final Value<String> userId;
  final Value<String> species;
  final Value<String> name;
  final Value<int> level;
  final Value<int> xp;
  final Value<int> hp;
  final Value<bool> isAlive;
  final Value<DateTime> createdAt;
  final Value<DateTime?> diedAt;
  final Value<String?> deathCause;
  const PetsCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.userId = const Value.absent(),
    this.species = const Value.absent(),
    this.name = const Value.absent(),
    this.level = const Value.absent(),
    this.xp = const Value.absent(),
    this.hp = const Value.absent(),
    this.isAlive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.diedAt = const Value.absent(),
    this.deathCause = const Value.absent(),
  });
  PetsCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    required String userId,
    required String species,
    required String name,
    this.level = const Value.absent(),
    this.xp = const Value.absent(),
    this.hp = const Value.absent(),
    this.isAlive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.diedAt = const Value.absent(),
    this.deathCause = const Value.absent(),
  }) : userId = Value(userId),
       species = Value(species),
       name = Value(name);
  static Insertable<Pet> custom({
    Expression<int>? id,
    Expression<String>? remoteId,
    Expression<String>? userId,
    Expression<String>? species,
    Expression<String>? name,
    Expression<int>? level,
    Expression<int>? xp,
    Expression<int>? hp,
    Expression<bool>? isAlive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? diedAt,
    Expression<String>? deathCause,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (userId != null) 'user_id': userId,
      if (species != null) 'species': species,
      if (name != null) 'name': name,
      if (level != null) 'level': level,
      if (xp != null) 'xp': xp,
      if (hp != null) 'hp': hp,
      if (isAlive != null) 'is_alive': isAlive,
      if (createdAt != null) 'created_at': createdAt,
      if (diedAt != null) 'died_at': diedAt,
      if (deathCause != null) 'death_cause': deathCause,
    });
  }

  PetsCompanion copyWith({
    Value<int>? id,
    Value<String?>? remoteId,
    Value<String>? userId,
    Value<String>? species,
    Value<String>? name,
    Value<int>? level,
    Value<int>? xp,
    Value<int>? hp,
    Value<bool>? isAlive,
    Value<DateTime>? createdAt,
    Value<DateTime?>? diedAt,
    Value<String?>? deathCause,
  }) {
    return PetsCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      species: species ?? this.species,
      name: name ?? this.name,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      hp: hp ?? this.hp,
      isAlive: isAlive ?? this.isAlive,
      createdAt: createdAt ?? this.createdAt,
      diedAt: diedAt ?? this.diedAt,
      deathCause: deathCause ?? this.deathCause,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (hp.present) {
      map['hp'] = Variable<int>(hp.value);
    }
    if (isAlive.present) {
      map['is_alive'] = Variable<bool>(isAlive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (diedAt.present) {
      map['died_at'] = Variable<DateTime>(diedAt.value);
    }
    if (deathCause.present) {
      map['death_cause'] = Variable<String>(deathCause.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PetsCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('userId: $userId, ')
          ..write('species: $species, ')
          ..write('name: $name, ')
          ..write('level: $level, ')
          ..write('xp: $xp, ')
          ..write('hp: $hp, ')
          ..write('isAlive: $isAlive, ')
          ..write('createdAt: $createdAt, ')
          ..write('diedAt: $diedAt, ')
          ..write('deathCause: $deathCause')
          ..write(')'))
        .toString();
  }
}

class $DailyScoresTable extends DailyScores
    with TableInfo<$DailyScoresTable, DailyScore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyScoresTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _focusRatioMeta = const VerificationMeta(
    'focusRatio',
  );
  @override
  late final GeneratedColumn<double> focusRatio = GeneratedColumn<double>(
    'focus_ratio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xpEarnedMeta = const VerificationMeta(
    'xpEarned',
  );
  @override
  late final GeneratedColumn<int> xpEarned = GeneratedColumn<int>(
    'xp_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hpChangeMeta = const VerificationMeta(
    'hpChange',
  );
  @override
  late final GeneratedColumn<int> hpChange = GeneratedColumn<int>(
    'hp_change',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalFocusMinutesMeta = const VerificationMeta(
    'totalFocusMinutes',
  );
  @override
  late final GeneratedColumn<int> totalFocusMinutes = GeneratedColumn<int>(
    'total_focus_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalBlacklistMinutesMeta =
      const VerificationMeta('totalBlacklistMinutes');
  @override
  late final GeneratedColumn<int> totalBlacklistMinutes = GeneratedColumn<int>(
    'total_blacklist_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
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
    remoteId,
    userId,
    date,
    focusRatio,
    grade,
    xpEarned,
    hpChange,
    totalFocusMinutes,
    totalBlacklistMinutes,
    mood,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_scores';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyScore> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('focus_ratio')) {
      context.handle(
        _focusRatioMeta,
        focusRatio.isAcceptableOrUnknown(data['focus_ratio']!, _focusRatioMeta),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('xp_earned')) {
      context.handle(
        _xpEarnedMeta,
        xpEarned.isAcceptableOrUnknown(data['xp_earned']!, _xpEarnedMeta),
      );
    }
    if (data.containsKey('hp_change')) {
      context.handle(
        _hpChangeMeta,
        hpChange.isAcceptableOrUnknown(data['hp_change']!, _hpChangeMeta),
      );
    }
    if (data.containsKey('total_focus_minutes')) {
      context.handle(
        _totalFocusMinutesMeta,
        totalFocusMinutes.isAcceptableOrUnknown(
          data['total_focus_minutes']!,
          _totalFocusMinutesMeta,
        ),
      );
    }
    if (data.containsKey('total_blacklist_minutes')) {
      context.handle(
        _totalBlacklistMinutesMeta,
        totalBlacklistMinutes.isAcceptableOrUnknown(
          data['total_blacklist_minutes']!,
          _totalBlacklistMinutesMeta,
        ),
      );
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
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
  DailyScore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyScore(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      focusRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}focus_ratio'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      )!,
      xpEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_earned'],
      )!,
      hpChange: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hp_change'],
      )!,
      totalFocusMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_focus_minutes'],
      )!,
      totalBlacklistMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_blacklist_minutes'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DailyScoresTable createAlias(String alias) {
    return $DailyScoresTable(attachedDatabase, alias);
  }
}

class DailyScore extends DataClass implements Insertable<DailyScore> {
  final int id;
  final String? remoteId;
  final String userId;
  final DateTime date;
  final double focusRatio;
  final String grade;
  final int xpEarned;
  final int hpChange;
  final int totalFocusMinutes;
  final int totalBlacklistMinutes;
  final int mood;
  final DateTime createdAt;
  const DailyScore({
    required this.id,
    this.remoteId,
    required this.userId,
    required this.date,
    required this.focusRatio,
    required this.grade,
    required this.xpEarned,
    required this.hpChange,
    required this.totalFocusMinutes,
    required this.totalBlacklistMinutes,
    required this.mood,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    map['focus_ratio'] = Variable<double>(focusRatio);
    map['grade'] = Variable<String>(grade);
    map['xp_earned'] = Variable<int>(xpEarned);
    map['hp_change'] = Variable<int>(hpChange);
    map['total_focus_minutes'] = Variable<int>(totalFocusMinutes);
    map['total_blacklist_minutes'] = Variable<int>(totalBlacklistMinutes);
    map['mood'] = Variable<int>(mood);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailyScoresCompanion toCompanion(bool nullToAbsent) {
    return DailyScoresCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      userId: Value(userId),
      date: Value(date),
      focusRatio: Value(focusRatio),
      grade: Value(grade),
      xpEarned: Value(xpEarned),
      hpChange: Value(hpChange),
      totalFocusMinutes: Value(totalFocusMinutes),
      totalBlacklistMinutes: Value(totalBlacklistMinutes),
      mood: Value(mood),
      createdAt: Value(createdAt),
    );
  }

  factory DailyScore.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyScore(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      focusRatio: serializer.fromJson<double>(json['focusRatio']),
      grade: serializer.fromJson<String>(json['grade']),
      xpEarned: serializer.fromJson<int>(json['xpEarned']),
      hpChange: serializer.fromJson<int>(json['hpChange']),
      totalFocusMinutes: serializer.fromJson<int>(json['totalFocusMinutes']),
      totalBlacklistMinutes: serializer.fromJson<int>(
        json['totalBlacklistMinutes'],
      ),
      mood: serializer.fromJson<int>(json['mood']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'focusRatio': serializer.toJson<double>(focusRatio),
      'grade': serializer.toJson<String>(grade),
      'xpEarned': serializer.toJson<int>(xpEarned),
      'hpChange': serializer.toJson<int>(hpChange),
      'totalFocusMinutes': serializer.toJson<int>(totalFocusMinutes),
      'totalBlacklistMinutes': serializer.toJson<int>(totalBlacklistMinutes),
      'mood': serializer.toJson<int>(mood),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyScore copyWith({
    int? id,
    Value<String?> remoteId = const Value.absent(),
    String? userId,
    DateTime? date,
    double? focusRatio,
    String? grade,
    int? xpEarned,
    int? hpChange,
    int? totalFocusMinutes,
    int? totalBlacklistMinutes,
    int? mood,
    DateTime? createdAt,
  }) => DailyScore(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    focusRatio: focusRatio ?? this.focusRatio,
    grade: grade ?? this.grade,
    xpEarned: xpEarned ?? this.xpEarned,
    hpChange: hpChange ?? this.hpChange,
    totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
    totalBlacklistMinutes: totalBlacklistMinutes ?? this.totalBlacklistMinutes,
    mood: mood ?? this.mood,
    createdAt: createdAt ?? this.createdAt,
  );
  DailyScore copyWithCompanion(DailyScoresCompanion data) {
    return DailyScore(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      focusRatio: data.focusRatio.present
          ? data.focusRatio.value
          : this.focusRatio,
      grade: data.grade.present ? data.grade.value : this.grade,
      xpEarned: data.xpEarned.present ? data.xpEarned.value : this.xpEarned,
      hpChange: data.hpChange.present ? data.hpChange.value : this.hpChange,
      totalFocusMinutes: data.totalFocusMinutes.present
          ? data.totalFocusMinutes.value
          : this.totalFocusMinutes,
      totalBlacklistMinutes: data.totalBlacklistMinutes.present
          ? data.totalBlacklistMinutes.value
          : this.totalBlacklistMinutes,
      mood: data.mood.present ? data.mood.value : this.mood,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyScore(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('focusRatio: $focusRatio, ')
          ..write('grade: $grade, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('hpChange: $hpChange, ')
          ..write('totalFocusMinutes: $totalFocusMinutes, ')
          ..write('totalBlacklistMinutes: $totalBlacklistMinutes, ')
          ..write('mood: $mood, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    userId,
    date,
    focusRatio,
    grade,
    xpEarned,
    hpChange,
    totalFocusMinutes,
    totalBlacklistMinutes,
    mood,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyScore &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.focusRatio == this.focusRatio &&
          other.grade == this.grade &&
          other.xpEarned == this.xpEarned &&
          other.hpChange == this.hpChange &&
          other.totalFocusMinutes == this.totalFocusMinutes &&
          other.totalBlacklistMinutes == this.totalBlacklistMinutes &&
          other.mood == this.mood &&
          other.createdAt == this.createdAt);
}

class DailyScoresCompanion extends UpdateCompanion<DailyScore> {
  final Value<int> id;
  final Value<String?> remoteId;
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<double> focusRatio;
  final Value<String> grade;
  final Value<int> xpEarned;
  final Value<int> hpChange;
  final Value<int> totalFocusMinutes;
  final Value<int> totalBlacklistMinutes;
  final Value<int> mood;
  final Value<DateTime> createdAt;
  const DailyScoresCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.focusRatio = const Value.absent(),
    this.grade = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.hpChange = const Value.absent(),
    this.totalFocusMinutes = const Value.absent(),
    this.totalBlacklistMinutes = const Value.absent(),
    this.mood = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DailyScoresCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    required String userId,
    required DateTime date,
    this.focusRatio = const Value.absent(),
    required String grade,
    this.xpEarned = const Value.absent(),
    this.hpChange = const Value.absent(),
    this.totalFocusMinutes = const Value.absent(),
    this.totalBlacklistMinutes = const Value.absent(),
    this.mood = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : userId = Value(userId),
       date = Value(date),
       grade = Value(grade);
  static Insertable<DailyScore> custom({
    Expression<int>? id,
    Expression<String>? remoteId,
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<double>? focusRatio,
    Expression<String>? grade,
    Expression<int>? xpEarned,
    Expression<int>? hpChange,
    Expression<int>? totalFocusMinutes,
    Expression<int>? totalBlacklistMinutes,
    Expression<int>? mood,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (focusRatio != null) 'focus_ratio': focusRatio,
      if (grade != null) 'grade': grade,
      if (xpEarned != null) 'xp_earned': xpEarned,
      if (hpChange != null) 'hp_change': hpChange,
      if (totalFocusMinutes != null) 'total_focus_minutes': totalFocusMinutes,
      if (totalBlacklistMinutes != null)
        'total_blacklist_minutes': totalBlacklistMinutes,
      if (mood != null) 'mood': mood,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DailyScoresCompanion copyWith({
    Value<int>? id,
    Value<String?>? remoteId,
    Value<String>? userId,
    Value<DateTime>? date,
    Value<double>? focusRatio,
    Value<String>? grade,
    Value<int>? xpEarned,
    Value<int>? hpChange,
    Value<int>? totalFocusMinutes,
    Value<int>? totalBlacklistMinutes,
    Value<int>? mood,
    Value<DateTime>? createdAt,
  }) {
    return DailyScoresCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      focusRatio: focusRatio ?? this.focusRatio,
      grade: grade ?? this.grade,
      xpEarned: xpEarned ?? this.xpEarned,
      hpChange: hpChange ?? this.hpChange,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      totalBlacklistMinutes:
          totalBlacklistMinutes ?? this.totalBlacklistMinutes,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (focusRatio.present) {
      map['focus_ratio'] = Variable<double>(focusRatio.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (xpEarned.present) {
      map['xp_earned'] = Variable<int>(xpEarned.value);
    }
    if (hpChange.present) {
      map['hp_change'] = Variable<int>(hpChange.value);
    }
    if (totalFocusMinutes.present) {
      map['total_focus_minutes'] = Variable<int>(totalFocusMinutes.value);
    }
    if (totalBlacklistMinutes.present) {
      map['total_blacklist_minutes'] = Variable<int>(
        totalBlacklistMinutes.value,
      );
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyScoresCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('focusRatio: $focusRatio, ')
          ..write('grade: $grade, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('hpChange: $hpChange, ')
          ..write('totalFocusMinutes: $totalFocusMinutes, ')
          ..write('totalBlacklistMinutes: $totalBlacklistMinutes, ')
          ..write('mood: $mood, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetTable,
    rowId,
    operation,
    payload,
    createdAt,
    isSynced,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final int id;
  final String targetTable;
  final String rowId;
  final String operation;
  final String payload;
  final DateTime createdAt;
  final bool isSynced;
  final DateTime? syncedAt;
  const OutboxData({
    required this.id,
    required this.targetTable,
    required this.rowId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    required this.isSynced,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_table'] = Variable<String>(targetTable);
    map['row_id'] = Variable<String>(rowId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      rowId: Value(rowId),
      operation: Value(operation),
      payload: Value(payload),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory OutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      id: serializer.fromJson<int>(json['id']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      rowId: serializer.fromJson<String>(json['rowId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'targetTable': serializer.toJson<String>(targetTable),
      'rowId': serializer.toJson<String>(rowId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  OutboxData copyWith({
    int? id,
    String? targetTable,
    String? rowId,
    String? operation,
    String? payload,
    DateTime? createdAt,
    bool? isSynced,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => OutboxData(
    id: id ?? this.id,
    targetTable: targetTable ?? this.targetTable,
    rowId: rowId ?? this.rowId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      id: data.id.present ? data.id.value : this.id,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('rowId: $rowId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetTable,
    rowId,
    operation,
    payload,
    createdAt,
    isSynced,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.rowId == this.rowId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced &&
          other.syncedAt == this.syncedAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<int> id;
  final Value<String> targetTable;
  final Value<String> rowId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  final Value<DateTime?> syncedAt;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.rowId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.id = const Value.absent(),
    required String targetTable,
    required String rowId,
    required String operation,
    required String payload,
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncedAt = const Value.absent(),
  }) : targetTable = Value(targetTable),
       rowId = Value(rowId),
       operation = Value(operation),
       payload = Value(payload);
  static Insertable<OutboxData> custom({
    Expression<int>? id,
    Expression<String>? targetTable,
    Expression<String>? rowId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'target_table': targetTable,
      if (rowId != null) 'row_id': rowId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? id,
    Value<String>? targetTable,
    Value<String>? rowId,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
    Value<DateTime?>? syncedAt,
  }) {
    return OutboxCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      rowId: rowId ?? this.rowId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('rowId: $rowId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  @override
  late final GeneratedColumn<int> scheduleId = GeneratedColumn<int>(
    'schedule_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedDurationMinMeta =
      const VerificationMeta('plannedDurationMin');
  @override
  late final GeneratedColumn<int> plannedDurationMin = GeneratedColumn<int>(
    'planned_duration_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _actualFocusMinMeta = const VerificationMeta(
    'actualFocusMin',
  );
  @override
  late final GeneratedColumn<int> actualFocusMin = GeneratedColumn<int>(
    'actual_focus_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _blacklistUsageMinMeta = const VerificationMeta(
    'blacklistUsageMin',
  );
  @override
  late final GeneratedColumn<int> blacklistUsageMin = GeneratedColumn<int>(
    'blacklist_usage_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _focusRatioMeta = const VerificationMeta(
    'focusRatio',
  );
  @override
  late final GeneratedColumn<double> focusRatio = GeneratedColumn<double>(
    'focus_ratio',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
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
    remoteId,
    userId,
    scheduleId,
    startTime,
    endTime,
    plannedDurationMin,
    actualFocusMin,
    blacklistUsageMin,
    focusRatio,
    grade,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('planned_duration_min')) {
      context.handle(
        _plannedDurationMinMeta,
        plannedDurationMin.isAcceptableOrUnknown(
          data['planned_duration_min']!,
          _plannedDurationMinMeta,
        ),
      );
    }
    if (data.containsKey('actual_focus_min')) {
      context.handle(
        _actualFocusMinMeta,
        actualFocusMin.isAcceptableOrUnknown(
          data['actual_focus_min']!,
          _actualFocusMinMeta,
        ),
      );
    }
    if (data.containsKey('blacklist_usage_min')) {
      context.handle(
        _blacklistUsageMinMeta,
        blacklistUsageMin.isAcceptableOrUnknown(
          data['blacklist_usage_min']!,
          _blacklistUsageMinMeta,
        ),
      );
    }
    if (data.containsKey('focus_ratio')) {
      context.handle(
        _focusRatioMeta,
        focusRatio.isAcceptableOrUnknown(data['focus_ratio']!, _focusRatioMeta),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_id'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      plannedDurationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_duration_min'],
      )!,
      actualFocusMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_focus_min'],
      )!,
      blacklistUsageMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}blacklist_usage_min'],
      )!,
      focusRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}focus_ratio'],
      ),
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final String? remoteId;
  final String userId;
  final int? scheduleId;
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedDurationMin;
  final int actualFocusMin;
  final int blacklistUsageMin;
  final double? focusRatio;
  final String? grade;
  final bool isActive;
  final DateTime createdAt;
  const Session({
    required this.id,
    this.remoteId,
    required this.userId,
    this.scheduleId,
    required this.startTime,
    this.endTime,
    required this.plannedDurationMin,
    required this.actualFocusMin,
    required this.blacklistUsageMin,
    this.focusRatio,
    this.grade,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || scheduleId != null) {
      map['schedule_id'] = Variable<int>(scheduleId);
    }
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['planned_duration_min'] = Variable<int>(plannedDurationMin);
    map['actual_focus_min'] = Variable<int>(actualFocusMin);
    map['blacklist_usage_min'] = Variable<int>(blacklistUsageMin);
    if (!nullToAbsent || focusRatio != null) {
      map['focus_ratio'] = Variable<double>(focusRatio);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<String>(grade);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      userId: Value(userId),
      scheduleId: scheduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleId),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      plannedDurationMin: Value(plannedDurationMin),
      actualFocusMin: Value(actualFocusMin),
      blacklistUsageMin: Value(blacklistUsageMin),
      focusRatio: focusRatio == null && nullToAbsent
          ? const Value.absent()
          : Value(focusRatio),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      userId: serializer.fromJson<String>(json['userId']),
      scheduleId: serializer.fromJson<int?>(json['scheduleId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      plannedDurationMin: serializer.fromJson<int>(json['plannedDurationMin']),
      actualFocusMin: serializer.fromJson<int>(json['actualFocusMin']),
      blacklistUsageMin: serializer.fromJson<int>(json['blacklistUsageMin']),
      focusRatio: serializer.fromJson<double?>(json['focusRatio']),
      grade: serializer.fromJson<String?>(json['grade']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'userId': serializer.toJson<String>(userId),
      'scheduleId': serializer.toJson<int?>(scheduleId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'plannedDurationMin': serializer.toJson<int>(plannedDurationMin),
      'actualFocusMin': serializer.toJson<int>(actualFocusMin),
      'blacklistUsageMin': serializer.toJson<int>(blacklistUsageMin),
      'focusRatio': serializer.toJson<double?>(focusRatio),
      'grade': serializer.toJson<String?>(grade),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Session copyWith({
    int? id,
    Value<String?> remoteId = const Value.absent(),
    String? userId,
    Value<int?> scheduleId = const Value.absent(),
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    int? plannedDurationMin,
    int? actualFocusMin,
    int? blacklistUsageMin,
    Value<double?> focusRatio = const Value.absent(),
    Value<String?> grade = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => Session(
    id: id ?? this.id,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    userId: userId ?? this.userId,
    scheduleId: scheduleId.present ? scheduleId.value : this.scheduleId,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    plannedDurationMin: plannedDurationMin ?? this.plannedDurationMin,
    actualFocusMin: actualFocusMin ?? this.actualFocusMin,
    blacklistUsageMin: blacklistUsageMin ?? this.blacklistUsageMin,
    focusRatio: focusRatio.present ? focusRatio.value : this.focusRatio,
    grade: grade.present ? grade.value : this.grade,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      userId: data.userId.present ? data.userId.value : this.userId,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      plannedDurationMin: data.plannedDurationMin.present
          ? data.plannedDurationMin.value
          : this.plannedDurationMin,
      actualFocusMin: data.actualFocusMin.present
          ? data.actualFocusMin.value
          : this.actualFocusMin,
      blacklistUsageMin: data.blacklistUsageMin.present
          ? data.blacklistUsageMin.value
          : this.blacklistUsageMin,
      focusRatio: data.focusRatio.present
          ? data.focusRatio.value
          : this.focusRatio,
      grade: data.grade.present ? data.grade.value : this.grade,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('userId: $userId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('plannedDurationMin: $plannedDurationMin, ')
          ..write('actualFocusMin: $actualFocusMin, ')
          ..write('blacklistUsageMin: $blacklistUsageMin, ')
          ..write('focusRatio: $focusRatio, ')
          ..write('grade: $grade, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    userId,
    scheduleId,
    startTime,
    endTime,
    plannedDurationMin,
    actualFocusMin,
    blacklistUsageMin,
    focusRatio,
    grade,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.userId == this.userId &&
          other.scheduleId == this.scheduleId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.plannedDurationMin == this.plannedDurationMin &&
          other.actualFocusMin == this.actualFocusMin &&
          other.blacklistUsageMin == this.blacklistUsageMin &&
          other.focusRatio == this.focusRatio &&
          other.grade == this.grade &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<String?> remoteId;
  final Value<String> userId;
  final Value<int?> scheduleId;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int> plannedDurationMin;
  final Value<int> actualFocusMin;
  final Value<int> blacklistUsageMin;
  final Value<double?> focusRatio;
  final Value<String?> grade;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.userId = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.plannedDurationMin = const Value.absent(),
    this.actualFocusMin = const Value.absent(),
    this.blacklistUsageMin = const Value.absent(),
    this.focusRatio = const Value.absent(),
    this.grade = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    required String userId,
    this.scheduleId = const Value.absent(),
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.plannedDurationMin = const Value.absent(),
    this.actualFocusMin = const Value.absent(),
    this.blacklistUsageMin = const Value.absent(),
    this.focusRatio = const Value.absent(),
    this.grade = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : userId = Value(userId),
       startTime = Value(startTime);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? remoteId,
    Expression<String>? userId,
    Expression<int>? scheduleId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? plannedDurationMin,
    Expression<int>? actualFocusMin,
    Expression<int>? blacklistUsageMin,
    Expression<double>? focusRatio,
    Expression<String>? grade,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (userId != null) 'user_id': userId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (plannedDurationMin != null)
        'planned_duration_min': plannedDurationMin,
      if (actualFocusMin != null) 'actual_focus_min': actualFocusMin,
      if (blacklistUsageMin != null) 'blacklist_usage_min': blacklistUsageMin,
      if (focusRatio != null) 'focus_ratio': focusRatio,
      if (grade != null) 'grade': grade,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String?>? remoteId,
    Value<String>? userId,
    Value<int?>? scheduleId,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<int>? plannedDurationMin,
    Value<int>? actualFocusMin,
    Value<int>? blacklistUsageMin,
    Value<double?>? focusRatio,
    Value<String?>? grade,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      scheduleId: scheduleId ?? this.scheduleId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDurationMin: plannedDurationMin ?? this.plannedDurationMin,
      actualFocusMin: actualFocusMin ?? this.actualFocusMin,
      blacklistUsageMin: blacklistUsageMin ?? this.blacklistUsageMin,
      focusRatio: focusRatio ?? this.focusRatio,
      grade: grade ?? this.grade,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<int>(scheduleId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (plannedDurationMin.present) {
      map['planned_duration_min'] = Variable<int>(plannedDurationMin.value);
    }
    if (actualFocusMin.present) {
      map['actual_focus_min'] = Variable<int>(actualFocusMin.value);
    }
    if (blacklistUsageMin.present) {
      map['blacklist_usage_min'] = Variable<int>(blacklistUsageMin.value);
    }
    if (focusRatio.present) {
      map['focus_ratio'] = Variable<double>(focusRatio.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('userId: $userId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('plannedDurationMin: $plannedDurationMin, ')
          ..write('actualFocusMin: $actualFocusMin, ')
          ..write('blacklistUsageMin: $blacklistUsageMin, ')
          ..write('focusRatio: $focusRatio, ')
          ..write('grade: $grade, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UsageLogsTable extends UsageLogs
    with TableInfo<$UsageLogsTable, UsageLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsageLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  @override
  late final GeneratedColumn<int> scheduleId = GeneratedColumn<int>(
    'schedule_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMsMeta = const VerificationMeta(
    'totalMs',
  );
  @override
  late final GeneratedColumn<int> totalMs = GeneratedColumn<int>(
    'total_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rangeStartMeta = const VerificationMeta(
    'rangeStart',
  );
  @override
  late final GeneratedColumn<DateTime> rangeStart = GeneratedColumn<DateTime>(
    'range_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rangeEndMeta = const VerificationMeta(
    'rangeEnd',
  );
  @override
  late final GeneratedColumn<DateTime> rangeEnd = GeneratedColumn<DateTime>(
    'range_end',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    scheduleId,
    packageName,
    totalMs,
    rangeStart,
    rangeEnd,
    capturedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usage_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsageLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('total_ms')) {
      context.handle(
        _totalMsMeta,
        totalMs.isAcceptableOrUnknown(data['total_ms']!, _totalMsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMsMeta);
    }
    if (data.containsKey('range_start')) {
      context.handle(
        _rangeStartMeta,
        rangeStart.isAcceptableOrUnknown(data['range_start']!, _rangeStartMeta),
      );
    } else if (isInserting) {
      context.missing(_rangeStartMeta);
    }
    if (data.containsKey('range_end')) {
      context.handle(
        _rangeEndMeta,
        rangeEnd.isAcceptableOrUnknown(data['range_end']!, _rangeEndMeta),
      );
    } else if (isInserting) {
      context.missing(_rangeEndMeta);
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
  UsageLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsageLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_id'],
      ),
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      totalMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_ms'],
      )!,
      rangeStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}range_start'],
      )!,
      rangeEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}range_end'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
    );
  }

  @override
  $UsageLogsTable createAlias(String alias) {
    return $UsageLogsTable(attachedDatabase, alias);
  }
}

class UsageLog extends DataClass implements Insertable<UsageLog> {
  final int id;

  /// 소유자 user id (text, supabase auth user id 또는 'local').
  final String userId;

  /// 어떤 일정 진행 중에 측정됐는지 (FK to schedules.id, nullable —
  /// 일정 외 시간에 수집된 경우 null).
  final int? scheduleId;

  /// 안드로이드 패키지명 (예: `com.android.chrome`).
  final String packageName;

  /// 해당 윈도 안에서 포그라운드로 누적된 시간 (ms).
  final int totalMs;

  /// 측정 윈도 시작 (paused 시각).
  final DateTime rangeStart;

  /// 측정 윈도 종료 (resumed 시각).
  final DateTime rangeEnd;

  /// 행 생성 시각.
  final DateTime capturedAt;
  const UsageLog({
    required this.id,
    required this.userId,
    this.scheduleId,
    required this.packageName,
    required this.totalMs,
    required this.rangeStart,
    required this.rangeEnd,
    required this.capturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || scheduleId != null) {
      map['schedule_id'] = Variable<int>(scheduleId);
    }
    map['package_name'] = Variable<String>(packageName);
    map['total_ms'] = Variable<int>(totalMs);
    map['range_start'] = Variable<DateTime>(rangeStart);
    map['range_end'] = Variable<DateTime>(rangeEnd);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    return map;
  }

  UsageLogsCompanion toCompanion(bool nullToAbsent) {
    return UsageLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      scheduleId: scheduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleId),
      packageName: Value(packageName),
      totalMs: Value(totalMs),
      rangeStart: Value(rangeStart),
      rangeEnd: Value(rangeEnd),
      capturedAt: Value(capturedAt),
    );
  }

  factory UsageLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsageLog(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      scheduleId: serializer.fromJson<int?>(json['scheduleId']),
      packageName: serializer.fromJson<String>(json['packageName']),
      totalMs: serializer.fromJson<int>(json['totalMs']),
      rangeStart: serializer.fromJson<DateTime>(json['rangeStart']),
      rangeEnd: serializer.fromJson<DateTime>(json['rangeEnd']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'scheduleId': serializer.toJson<int?>(scheduleId),
      'packageName': serializer.toJson<String>(packageName),
      'totalMs': serializer.toJson<int>(totalMs),
      'rangeStart': serializer.toJson<DateTime>(rangeStart),
      'rangeEnd': serializer.toJson<DateTime>(rangeEnd),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
    };
  }

  UsageLog copyWith({
    int? id,
    String? userId,
    Value<int?> scheduleId = const Value.absent(),
    String? packageName,
    int? totalMs,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    DateTime? capturedAt,
  }) => UsageLog(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    scheduleId: scheduleId.present ? scheduleId.value : this.scheduleId,
    packageName: packageName ?? this.packageName,
    totalMs: totalMs ?? this.totalMs,
    rangeStart: rangeStart ?? this.rangeStart,
    rangeEnd: rangeEnd ?? this.rangeEnd,
    capturedAt: capturedAt ?? this.capturedAt,
  );
  UsageLog copyWithCompanion(UsageLogsCompanion data) {
    return UsageLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      totalMs: data.totalMs.present ? data.totalMs.value : this.totalMs,
      rangeStart: data.rangeStart.present
          ? data.rangeStart.value
          : this.rangeStart,
      rangeEnd: data.rangeEnd.present ? data.rangeEnd.value : this.rangeEnd,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsageLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('packageName: $packageName, ')
          ..write('totalMs: $totalMs, ')
          ..write('rangeStart: $rangeStart, ')
          ..write('rangeEnd: $rangeEnd, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    scheduleId,
    packageName,
    totalMs,
    rangeStart,
    rangeEnd,
    capturedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsageLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.scheduleId == this.scheduleId &&
          other.packageName == this.packageName &&
          other.totalMs == this.totalMs &&
          other.rangeStart == this.rangeStart &&
          other.rangeEnd == this.rangeEnd &&
          other.capturedAt == this.capturedAt);
}

class UsageLogsCompanion extends UpdateCompanion<UsageLog> {
  final Value<int> id;
  final Value<String> userId;
  final Value<int?> scheduleId;
  final Value<String> packageName;
  final Value<int> totalMs;
  final Value<DateTime> rangeStart;
  final Value<DateTime> rangeEnd;
  final Value<DateTime> capturedAt;
  const UsageLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.packageName = const Value.absent(),
    this.totalMs = const Value.absent(),
    this.rangeStart = const Value.absent(),
    this.rangeEnd = const Value.absent(),
    this.capturedAt = const Value.absent(),
  });
  UsageLogsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    this.scheduleId = const Value.absent(),
    required String packageName,
    required int totalMs,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    this.capturedAt = const Value.absent(),
  }) : userId = Value(userId),
       packageName = Value(packageName),
       totalMs = Value(totalMs),
       rangeStart = Value(rangeStart),
       rangeEnd = Value(rangeEnd);
  static Insertable<UsageLog> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<int>? scheduleId,
    Expression<String>? packageName,
    Expression<int>? totalMs,
    Expression<DateTime>? rangeStart,
    Expression<DateTime>? rangeEnd,
    Expression<DateTime>? capturedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (packageName != null) 'package_name': packageName,
      if (totalMs != null) 'total_ms': totalMs,
      if (rangeStart != null) 'range_start': rangeStart,
      if (rangeEnd != null) 'range_end': rangeEnd,
      if (capturedAt != null) 'captured_at': capturedAt,
    });
  }

  UsageLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<int?>? scheduleId,
    Value<String>? packageName,
    Value<int>? totalMs,
    Value<DateTime>? rangeStart,
    Value<DateTime>? rangeEnd,
    Value<DateTime>? capturedAt,
  }) {
    return UsageLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      scheduleId: scheduleId ?? this.scheduleId,
      packageName: packageName ?? this.packageName,
      totalMs: totalMs ?? this.totalMs,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<int>(scheduleId.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (totalMs.present) {
      map['total_ms'] = Variable<int>(totalMs.value);
    }
    if (rangeStart.present) {
      map['range_start'] = Variable<DateTime>(rangeStart.value);
    }
    if (rangeEnd.present) {
      map['range_end'] = Variable<DateTime>(rangeEnd.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsageLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('packageName: $packageName, ')
          ..write('totalMs: $totalMs, ')
          ..write('rangeStart: $rangeStart, ')
          ..write('rangeEnd: $rangeEnd, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $PetsTable pets = $PetsTable(this);
  late final $DailyScoresTable dailyScores = $DailyScoresTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $UsageLogsTable usageLogs = $UsageLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    schedules,
    pets,
    dailyScores,
    outbox,
    sessions,
    usageLogs,
  ];
}

typedef $$SchedulesTableCreateCompanionBuilder =
    SchedulesCompanion Function({
      Value<int> id,
      Value<String?> remoteId,
      required String userId,
      required String title,
      required String category,
      Value<String> tags,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      Value<bool> isTodo,
      Value<bool> isCompleted,
      Value<DateTime?> deletedAt,
      Value<bool> allowDisruption,
      Value<int> disruptionIntensity,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$SchedulesTableUpdateCompanionBuilder =
    SchedulesCompanion Function({
      Value<int> id,
      Value<String?> remoteId,
      Value<String> userId,
      Value<String> title,
      Value<String> category,
      Value<String> tags,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      Value<bool> isTodo,
      Value<bool> isCompleted,
      Value<DateTime?> deletedAt,
      Value<bool> allowDisruption,
      Value<int> disruptionIntensity,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$SchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTodo => $composableBuilder(
    column: $table.isTodo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowDisruption => $composableBuilder(
    column: $table.allowDisruption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get disruptionIntensity => $composableBuilder(
    column: $table.disruptionIntensity,
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

class $$SchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTodo => $composableBuilder(
    column: $table.isTodo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowDisruption => $composableBuilder(
    column: $table.allowDisruption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get disruptionIntensity => $composableBuilder(
    column: $table.disruptionIntensity,
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

class $$SchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<bool> get isTodo =>
      $composableBuilder(column: $table.isTodo, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get allowDisruption => $composableBuilder(
    column: $table.allowDisruption,
    builder: (column) => column,
  );

  GeneratedColumn<int> get disruptionIntensity => $composableBuilder(
    column: $table.disruptionIntensity,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchedulesTable,
          Schedule,
          $$SchedulesTableFilterComposer,
          $$SchedulesTableOrderingComposer,
          $$SchedulesTableAnnotationComposer,
          $$SchedulesTableCreateCompanionBuilder,
          $$SchedulesTableUpdateCompanionBuilder,
          (Schedule, BaseReferences<_$AppDatabase, $SchedulesTable, Schedule>),
          Schedule,
          PrefetchHooks Function()
        > {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<bool> isTodo = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> allowDisruption = const Value.absent(),
                Value<int> disruptionIntensity = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SchedulesCompanion(
                id: id,
                remoteId: remoteId,
                userId: userId,
                title: title,
                category: category,
                tags: tags,
                startTime: startTime,
                endTime: endTime,
                isTodo: isTodo,
                isCompleted: isCompleted,
                deletedAt: deletedAt,
                allowDisruption: allowDisruption,
                disruptionIntensity: disruptionIntensity,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                required String userId,
                required String title,
                required String category,
                Value<String> tags = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<bool> isTodo = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> allowDisruption = const Value.absent(),
                Value<int> disruptionIntensity = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SchedulesCompanion.insert(
                id: id,
                remoteId: remoteId,
                userId: userId,
                title: title,
                category: category,
                tags: tags,
                startTime: startTime,
                endTime: endTime,
                isTodo: isTodo,
                isCompleted: isCompleted,
                deletedAt: deletedAt,
                allowDisruption: allowDisruption,
                disruptionIntensity: disruptionIntensity,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchedulesTable,
      Schedule,
      $$SchedulesTableFilterComposer,
      $$SchedulesTableOrderingComposer,
      $$SchedulesTableAnnotationComposer,
      $$SchedulesTableCreateCompanionBuilder,
      $$SchedulesTableUpdateCompanionBuilder,
      (Schedule, BaseReferences<_$AppDatabase, $SchedulesTable, Schedule>),
      Schedule,
      PrefetchHooks Function()
    >;
typedef $$PetsTableCreateCompanionBuilder =
    PetsCompanion Function({
      Value<int> id,
      Value<String?> remoteId,
      required String userId,
      required String species,
      required String name,
      Value<int> level,
      Value<int> xp,
      Value<int> hp,
      Value<bool> isAlive,
      Value<DateTime> createdAt,
      Value<DateTime?> diedAt,
      Value<String?> deathCause,
    });
typedef $$PetsTableUpdateCompanionBuilder =
    PetsCompanion Function({
      Value<int> id,
      Value<String?> remoteId,
      Value<String> userId,
      Value<String> species,
      Value<String> name,
      Value<int> level,
      Value<int> xp,
      Value<int> hp,
      Value<bool> isAlive,
      Value<DateTime> createdAt,
      Value<DateTime?> diedAt,
      Value<String?> deathCause,
    });

class $$PetsTableFilterComposer extends Composer<_$AppDatabase, $PetsTable> {
  $$PetsTableFilterComposer({
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hp => $composableBuilder(
    column: $table.hp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAlive => $composableBuilder(
    column: $table.isAlive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get diedAt => $composableBuilder(
    column: $table.diedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deathCause => $composableBuilder(
    column: $table.deathCause,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PetsTableOrderingComposer extends Composer<_$AppDatabase, $PetsTable> {
  $$PetsTableOrderingComposer({
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hp => $composableBuilder(
    column: $table.hp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAlive => $composableBuilder(
    column: $table.isAlive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get diedAt => $composableBuilder(
    column: $table.diedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deathCause => $composableBuilder(
    column: $table.deathCause,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PetsTable> {
  $$PetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<int> get hp =>
      $composableBuilder(column: $table.hp, builder: (column) => column);

  GeneratedColumn<bool> get isAlive =>
      $composableBuilder(column: $table.isAlive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get diedAt =>
      $composableBuilder(column: $table.diedAt, builder: (column) => column);

  GeneratedColumn<String> get deathCause => $composableBuilder(
    column: $table.deathCause,
    builder: (column) => column,
  );
}

class $$PetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PetsTable,
          Pet,
          $$PetsTableFilterComposer,
          $$PetsTableOrderingComposer,
          $$PetsTableAnnotationComposer,
          $$PetsTableCreateCompanionBuilder,
          $$PetsTableUpdateCompanionBuilder,
          (Pet, BaseReferences<_$AppDatabase, $PetsTable, Pet>),
          Pet,
          PrefetchHooks Function()
        > {
  $$PetsTableTableManager(_$AppDatabase db, $PetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> species = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> hp = const Value.absent(),
                Value<bool> isAlive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> diedAt = const Value.absent(),
                Value<String?> deathCause = const Value.absent(),
              }) => PetsCompanion(
                id: id,
                remoteId: remoteId,
                userId: userId,
                species: species,
                name: name,
                level: level,
                xp: xp,
                hp: hp,
                isAlive: isAlive,
                createdAt: createdAt,
                diedAt: diedAt,
                deathCause: deathCause,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                required String userId,
                required String species,
                required String name,
                Value<int> level = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> hp = const Value.absent(),
                Value<bool> isAlive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> diedAt = const Value.absent(),
                Value<String?> deathCause = const Value.absent(),
              }) => PetsCompanion.insert(
                id: id,
                remoteId: remoteId,
                userId: userId,
                species: species,
                name: name,
                level: level,
                xp: xp,
                hp: hp,
                isAlive: isAlive,
                createdAt: createdAt,
                diedAt: diedAt,
                deathCause: deathCause,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PetsTable,
      Pet,
      $$PetsTableFilterComposer,
      $$PetsTableOrderingComposer,
      $$PetsTableAnnotationComposer,
      $$PetsTableCreateCompanionBuilder,
      $$PetsTableUpdateCompanionBuilder,
      (Pet, BaseReferences<_$AppDatabase, $PetsTable, Pet>),
      Pet,
      PrefetchHooks Function()
    >;
typedef $$DailyScoresTableCreateCompanionBuilder =
    DailyScoresCompanion Function({
      Value<int> id,
      Value<String?> remoteId,
      required String userId,
      required DateTime date,
      Value<double> focusRatio,
      required String grade,
      Value<int> xpEarned,
      Value<int> hpChange,
      Value<int> totalFocusMinutes,
      Value<int> totalBlacklistMinutes,
      Value<int> mood,
      Value<DateTime> createdAt,
    });
typedef $$DailyScoresTableUpdateCompanionBuilder =
    DailyScoresCompanion Function({
      Value<int> id,
      Value<String?> remoteId,
      Value<String> userId,
      Value<DateTime> date,
      Value<double> focusRatio,
      Value<String> grade,
      Value<int> xpEarned,
      Value<int> hpChange,
      Value<int> totalFocusMinutes,
      Value<int> totalBlacklistMinutes,
      Value<int> mood,
      Value<DateTime> createdAt,
    });

class $$DailyScoresTableFilterComposer
    extends Composer<_$AppDatabase, $DailyScoresTable> {
  $$DailyScoresTableFilterComposer({
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get focusRatio => $composableBuilder(
    column: $table.focusRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hpChange => $composableBuilder(
    column: $table.hpChange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalFocusMinutes => $composableBuilder(
    column: $table.totalFocusMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBlacklistMinutes => $composableBuilder(
    column: $table.totalBlacklistMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyScoresTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyScoresTable> {
  $$DailyScoresTableOrderingComposer({
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get focusRatio => $composableBuilder(
    column: $table.focusRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hpChange => $composableBuilder(
    column: $table.hpChange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalFocusMinutes => $composableBuilder(
    column: $table.totalFocusMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBlacklistMinutes => $composableBuilder(
    column: $table.totalBlacklistMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyScoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyScoresTable> {
  $$DailyScoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get focusRatio => $composableBuilder(
    column: $table.focusRatio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<int> get xpEarned =>
      $composableBuilder(column: $table.xpEarned, builder: (column) => column);

  GeneratedColumn<int> get hpChange =>
      $composableBuilder(column: $table.hpChange, builder: (column) => column);

  GeneratedColumn<int> get totalFocusMinutes => $composableBuilder(
    column: $table.totalFocusMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBlacklistMinutes => $composableBuilder(
    column: $table.totalBlacklistMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DailyScoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyScoresTable,
          DailyScore,
          $$DailyScoresTableFilterComposer,
          $$DailyScoresTableOrderingComposer,
          $$DailyScoresTableAnnotationComposer,
          $$DailyScoresTableCreateCompanionBuilder,
          $$DailyScoresTableUpdateCompanionBuilder,
          (
            DailyScore,
            BaseReferences<_$AppDatabase, $DailyScoresTable, DailyScore>,
          ),
          DailyScore,
          PrefetchHooks Function()
        > {
  $$DailyScoresTableTableManager(_$AppDatabase db, $DailyScoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyScoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyScoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyScoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> focusRatio = const Value.absent(),
                Value<String> grade = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
                Value<int> hpChange = const Value.absent(),
                Value<int> totalFocusMinutes = const Value.absent(),
                Value<int> totalBlacklistMinutes = const Value.absent(),
                Value<int> mood = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DailyScoresCompanion(
                id: id,
                remoteId: remoteId,
                userId: userId,
                date: date,
                focusRatio: focusRatio,
                grade: grade,
                xpEarned: xpEarned,
                hpChange: hpChange,
                totalFocusMinutes: totalFocusMinutes,
                totalBlacklistMinutes: totalBlacklistMinutes,
                mood: mood,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                required String userId,
                required DateTime date,
                Value<double> focusRatio = const Value.absent(),
                required String grade,
                Value<int> xpEarned = const Value.absent(),
                Value<int> hpChange = const Value.absent(),
                Value<int> totalFocusMinutes = const Value.absent(),
                Value<int> totalBlacklistMinutes = const Value.absent(),
                Value<int> mood = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DailyScoresCompanion.insert(
                id: id,
                remoteId: remoteId,
                userId: userId,
                date: date,
                focusRatio: focusRatio,
                grade: grade,
                xpEarned: xpEarned,
                hpChange: hpChange,
                totalFocusMinutes: totalFocusMinutes,
                totalBlacklistMinutes: totalBlacklistMinutes,
                mood: mood,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyScoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyScoresTable,
      DailyScore,
      $$DailyScoresTableFilterComposer,
      $$DailyScoresTableOrderingComposer,
      $$DailyScoresTableAnnotationComposer,
      $$DailyScoresTableCreateCompanionBuilder,
      $$DailyScoresTableUpdateCompanionBuilder,
      (
        DailyScore,
        BaseReferences<_$AppDatabase, $DailyScoresTable, DailyScore>,
      ),
      DailyScore,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> id,
      required String targetTable,
      required String rowId,
      required String operation,
      required String payload,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
      Value<DateTime?> syncedAt,
    });
typedef $$OutboxTableUpdateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> id,
      Value<String> targetTable,
      Value<String> rowId,
      Value<String> operation,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
      Value<DateTime?> syncedAt,
    });

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
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

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
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

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxData,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
          OutboxData,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => OutboxCompanion(
                id: id,
                targetTable: targetTable,
                rowId: rowId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                isSynced: isSynced,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String targetTable,
                required String rowId,
                required String operation,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => OutboxCompanion.insert(
                id: id,
                targetTable: targetTable,
                rowId: rowId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                isSynced: isSynced,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxData,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
      OutboxData,
      PrefetchHooks Function()
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<String?> remoteId,
      required String userId,
      Value<int?> scheduleId,
      required DateTime startTime,
      Value<DateTime?> endTime,
      Value<int> plannedDurationMin,
      Value<int> actualFocusMin,
      Value<int> blacklistUsageMin,
      Value<double?> focusRatio,
      Value<String?> grade,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<String?> remoteId,
      Value<String> userId,
      Value<int?> scheduleId,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<int> plannedDurationMin,
      Value<int> actualFocusMin,
      Value<int> blacklistUsageMin,
      Value<double?> focusRatio,
      Value<String?> grade,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDurationMin => $composableBuilder(
    column: $table.plannedDurationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualFocusMin => $composableBuilder(
    column: $table.actualFocusMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get blacklistUsageMin => $composableBuilder(
    column: $table.blacklistUsageMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get focusRatio => $composableBuilder(
    column: $table.focusRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDurationMin => $composableBuilder(
    column: $table.plannedDurationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualFocusMin => $composableBuilder(
    column: $table.actualFocusMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get blacklistUsageMin => $composableBuilder(
    column: $table.blacklistUsageMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get focusRatio => $composableBuilder(
    column: $table.focusRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get plannedDurationMin => $composableBuilder(
    column: $table.plannedDurationMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualFocusMin => $composableBuilder(
    column: $table.actualFocusMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get blacklistUsageMin => $composableBuilder(
    column: $table.blacklistUsageMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get focusRatio => $composableBuilder(
    column: $table.focusRatio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int?> scheduleId = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> plannedDurationMin = const Value.absent(),
                Value<int> actualFocusMin = const Value.absent(),
                Value<int> blacklistUsageMin = const Value.absent(),
                Value<double?> focusRatio = const Value.absent(),
                Value<String?> grade = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                remoteId: remoteId,
                userId: userId,
                scheduleId: scheduleId,
                startTime: startTime,
                endTime: endTime,
                plannedDurationMin: plannedDurationMin,
                actualFocusMin: actualFocusMin,
                blacklistUsageMin: blacklistUsageMin,
                focusRatio: focusRatio,
                grade: grade,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                required String userId,
                Value<int?> scheduleId = const Value.absent(),
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> plannedDurationMin = const Value.absent(),
                Value<int> actualFocusMin = const Value.absent(),
                Value<int> blacklistUsageMin = const Value.absent(),
                Value<double?> focusRatio = const Value.absent(),
                Value<String?> grade = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                remoteId: remoteId,
                userId: userId,
                scheduleId: scheduleId,
                startTime: startTime,
                endTime: endTime,
                plannedDurationMin: plannedDurationMin,
                actualFocusMin: actualFocusMin,
                blacklistUsageMin: blacklistUsageMin,
                focusRatio: focusRatio,
                grade: grade,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;
typedef $$UsageLogsTableCreateCompanionBuilder =
    UsageLogsCompanion Function({
      Value<int> id,
      required String userId,
      Value<int?> scheduleId,
      required String packageName,
      required int totalMs,
      required DateTime rangeStart,
      required DateTime rangeEnd,
      Value<DateTime> capturedAt,
    });
typedef $$UsageLogsTableUpdateCompanionBuilder =
    UsageLogsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int?> scheduleId,
      Value<String> packageName,
      Value<int> totalMs,
      Value<DateTime> rangeStart,
      Value<DateTime> rangeEnd,
      Value<DateTime> capturedAt,
    });

class $$UsageLogsTableFilterComposer
    extends Composer<_$AppDatabase, $UsageLogsTable> {
  $$UsageLogsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMs => $composableBuilder(
    column: $table.totalMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rangeStart => $composableBuilder(
    column: $table.rangeStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rangeEnd => $composableBuilder(
    column: $table.rangeEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsageLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $UsageLogsTable> {
  $$UsageLogsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMs => $composableBuilder(
    column: $table.totalMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rangeStart => $composableBuilder(
    column: $table.rangeStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rangeEnd => $composableBuilder(
    column: $table.rangeEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsageLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsageLogsTable> {
  $$UsageLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalMs =>
      $composableBuilder(column: $table.totalMs, builder: (column) => column);

  GeneratedColumn<DateTime> get rangeStart => $composableBuilder(
    column: $table.rangeStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get rangeEnd =>
      $composableBuilder(column: $table.rangeEnd, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );
}

class $$UsageLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsageLogsTable,
          UsageLog,
          $$UsageLogsTableFilterComposer,
          $$UsageLogsTableOrderingComposer,
          $$UsageLogsTableAnnotationComposer,
          $$UsageLogsTableCreateCompanionBuilder,
          $$UsageLogsTableUpdateCompanionBuilder,
          (UsageLog, BaseReferences<_$AppDatabase, $UsageLogsTable, UsageLog>),
          UsageLog,
          PrefetchHooks Function()
        > {
  $$UsageLogsTableTableManager(_$AppDatabase db, $UsageLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsageLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsageLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsageLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int?> scheduleId = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<int> totalMs = const Value.absent(),
                Value<DateTime> rangeStart = const Value.absent(),
                Value<DateTime> rangeEnd = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
              }) => UsageLogsCompanion(
                id: id,
                userId: userId,
                scheduleId: scheduleId,
                packageName: packageName,
                totalMs: totalMs,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                capturedAt: capturedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                Value<int?> scheduleId = const Value.absent(),
                required String packageName,
                required int totalMs,
                required DateTime rangeStart,
                required DateTime rangeEnd,
                Value<DateTime> capturedAt = const Value.absent(),
              }) => UsageLogsCompanion.insert(
                id: id,
                userId: userId,
                scheduleId: scheduleId,
                packageName: packageName,
                totalMs: totalMs,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                capturedAt: capturedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsageLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsageLogsTable,
      UsageLog,
      $$UsageLogsTableFilterComposer,
      $$UsageLogsTableOrderingComposer,
      $$UsageLogsTableAnnotationComposer,
      $$UsageLogsTableCreateCompanionBuilder,
      $$UsageLogsTableUpdateCompanionBuilder,
      (UsageLog, BaseReferences<_$AppDatabase, $UsageLogsTable, UsageLog>),
      UsageLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
  $$PetsTableTableManager get pets => $$PetsTableTableManager(_db, _db.pets);
  $$DailyScoresTableTableManager get dailyScores =>
      $$DailyScoresTableTableManager(_db, _db.dailyScores);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$UsageLogsTableTableManager get usageLogs =>
      $$UsageLogsTableTableManager(_db, _db.usageLogs);
}
