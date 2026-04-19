// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SyncQueuesTable extends SyncQueues
    with TableInfo<$SyncQueuesTable, SyncQueue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _actionTypeMeta =
      const VerificationMeta('actionType');
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
      'action_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, actionType, payload, status, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queues';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueue> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
          _actionTypeMeta,
          actionType.isAcceptableOrUnknown(
              data['action_type']!, _actionTypeMeta));
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueue(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      actionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_type'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncQueuesTable createAlias(String alias) {
    return $SyncQueuesTable(attachedDatabase, alias);
  }
}

class SyncQueue extends DataClass implements Insertable<SyncQueue> {
  /// Auto-incrementing primary key.
  final int id;

  /// The type of action performed (e.g., 'CREATE_STORY', 'UPDATE_PROFILE').
  final String actionType;

  /// JSON-encoded payload containing the data to sync with the backend.
  final String payload;

  /// Current sync status: 'pending', 'processing', or 'failed'.
  final String status;

  /// Timestamp of when the action was queued.
  final DateTime createdAt;
  const SyncQueue(
      {required this.id,
      required this.actionType,
      required this.payload,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action_type'] = Variable<String>(actionType);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueuesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueuesCompanion(
      id: Value(id),
      actionType: Value(actionType),
      payload: Value(payload),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueue.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueue(
      id: serializer.fromJson<int>(json['id']),
      actionType: serializer.fromJson<String>(json['actionType']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'actionType': serializer.toJson<String>(actionType),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueue copyWith(
          {int? id,
          String? actionType,
          String? payload,
          String? status,
          DateTime? createdAt}) =>
      SyncQueue(
        id: id ?? this.id,
        actionType: actionType ?? this.actionType,
        payload: payload ?? this.payload,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncQueue copyWithCompanion(SyncQueuesCompanion data) {
    return SyncQueue(
      id: data.id.present ? data.id.value : this.id,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueue(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, actionType, payload, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueue &&
          other.id == this.id &&
          other.actionType == this.actionType &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class SyncQueuesCompanion extends UpdateCompanion<SyncQueue> {
  final Value<int> id;
  final Value<String> actionType;
  final Value<String> payload;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const SyncQueuesCompanion({
    this.id = const Value.absent(),
    this.actionType = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueuesCompanion.insert({
    this.id = const Value.absent(),
    required String actionType,
    required String payload,
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : actionType = Value(actionType),
        payload = Value(payload);
  static Insertable<SyncQueue> custom({
    Expression<int>? id,
    Expression<String>? actionType,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionType != null) 'action_type': actionType,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueuesCompanion copyWith(
      {Value<int>? id,
      Value<String>? actionType,
      Value<String>? payload,
      Value<String>? status,
      Value<DateTime>? createdAt}) {
    return SyncQueuesCompanion(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueuesCompanion(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StoriesTableTable extends StoriesTable
    with TableInfo<$StoriesTableTable, StoryEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coverColorMeta =
      const VerificationMeta('coverColor');
  @override
  late final GeneratedColumn<String> coverColor = GeneratedColumn<String>(
      'cover_color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coverEmojiMeta =
      const VerificationMeta('coverEmoji');
  @override
  late final GeneratedColumn<String> coverEmoji = GeneratedColumn<String>(
      'cover_emoji', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, coverColor, coverEmoji, isFavorite, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stories_table';
  @override
  VerificationContext validateIntegrity(Insertable<StoryEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover_color')) {
      context.handle(
          _coverColorMeta,
          coverColor.isAcceptableOrUnknown(
              data['cover_color']!, _coverColorMeta));
    } else if (isInserting) {
      context.missing(_coverColorMeta);
    }
    if (data.containsKey('cover_emoji')) {
      context.handle(
          _coverEmojiMeta,
          coverEmoji.isAcceptableOrUnknown(
              data['cover_emoji']!, _coverEmojiMeta));
    } else if (isInserting) {
      context.missing(_coverEmojiMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoryEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoryEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      coverColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_color'])!,
      coverEmoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_emoji'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $StoriesTableTable createAlias(String alias) {
    return $StoriesTableTable(attachedDatabase, alias);
  }
}

class StoryEntity extends DataClass implements Insertable<StoryEntity> {
  /// The unique UUID of the story.
  final String id;

  /// The title of the story.
  final String title;

  /// The background hex color for the cover.
  final String coverColor;

  /// The emoji displayed on the cover.
  final String coverEmoji;

  /// Indicates if the story is favorited by the local user.
  final bool isFavorite;

  /// When the story was first created.
  final DateTime createdAt;

  /// When the story was last modified.
  final DateTime updatedAt;
  const StoryEntity(
      {required this.id,
      required this.title,
      required this.coverColor,
      required this.coverEmoji,
      required this.isFavorite,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['cover_color'] = Variable<String>(coverColor);
    map['cover_emoji'] = Variable<String>(coverEmoji);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StoriesTableCompanion toCompanion(bool nullToAbsent) {
    return StoriesTableCompanion(
      id: Value(id),
      title: Value(title),
      coverColor: Value(coverColor),
      coverEmoji: Value(coverEmoji),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StoryEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoryEntity(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      coverColor: serializer.fromJson<String>(json['coverColor']),
      coverEmoji: serializer.fromJson<String>(json['coverEmoji']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
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
      'coverColor': serializer.toJson<String>(coverColor),
      'coverEmoji': serializer.toJson<String>(coverEmoji),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StoryEntity copyWith(
          {String? id,
          String? title,
          String? coverColor,
          String? coverEmoji,
          bool? isFavorite,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      StoryEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        coverColor: coverColor ?? this.coverColor,
        coverEmoji: coverEmoji ?? this.coverEmoji,
        isFavorite: isFavorite ?? this.isFavorite,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  StoryEntity copyWithCompanion(StoriesTableCompanion data) {
    return StoryEntity(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      coverColor:
          data.coverColor.present ? data.coverColor.value : this.coverColor,
      coverEmoji:
          data.coverEmoji.present ? data.coverEmoji.value : this.coverEmoji,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoryEntity(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('coverColor: $coverColor, ')
          ..write('coverEmoji: $coverEmoji, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, coverColor, coverEmoji, isFavorite, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoryEntity &&
          other.id == this.id &&
          other.title == this.title &&
          other.coverColor == this.coverColor &&
          other.coverEmoji == this.coverEmoji &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StoriesTableCompanion extends UpdateCompanion<StoryEntity> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> coverColor;
  final Value<String> coverEmoji;
  final Value<bool> isFavorite;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StoriesTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.coverColor = const Value.absent(),
    this.coverEmoji = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoriesTableCompanion.insert({
    required String id,
    required String title,
    required String coverColor,
    required String coverEmoji,
    this.isFavorite = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        coverColor = Value(coverColor),
        coverEmoji = Value(coverEmoji),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<StoryEntity> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? coverColor,
    Expression<String>? coverEmoji,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (coverColor != null) 'cover_color': coverColor,
      if (coverEmoji != null) 'cover_emoji': coverEmoji,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoriesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? coverColor,
      Value<String>? coverEmoji,
      Value<bool>? isFavorite,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return StoriesTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      coverColor: coverColor ?? this.coverColor,
      coverEmoji: coverEmoji ?? this.coverEmoji,
      isFavorite: isFavorite ?? this.isFavorite,
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
    if (coverColor.present) {
      map['cover_color'] = Variable<String>(coverColor.value);
    }
    if (coverEmoji.present) {
      map['cover_emoji'] = Variable<String>(coverEmoji.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
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
    return (StringBuffer('StoriesTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('coverColor: $coverColor, ')
          ..write('coverEmoji: $coverEmoji, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoryPagesTableTable extends StoryPagesTable
    with TableInfo<$StoryPagesTableTable, StoryPageEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoryPagesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storyIdMeta =
      const VerificationMeta('storyId');
  @override
  late final GeneratedColumn<String> storyId = GeneratedColumn<String>(
      'story_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES stories_table (id) ON DELETE CASCADE'));
  static const VerificationMeta _textContentMeta =
      const VerificationMeta('textContent');
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
      'text_content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageDescriptionMeta =
      const VerificationMeta('imageDescription');
  @override
  late final GeneratedColumn<String> imageDescription = GeneratedColumn<String>(
      'image_description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _backgroundColorMeta =
      const VerificationMeta('backgroundColor');
  @override
  late final GeneratedColumn<String> backgroundColor = GeneratedColumn<String>(
      'background_color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, storyId, textContent, imageDescription, backgroundColor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'story_pages_table';
  @override
  VerificationContext validateIntegrity(Insertable<StoryPageEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('story_id')) {
      context.handle(_storyIdMeta,
          storyId.isAcceptableOrUnknown(data['story_id']!, _storyIdMeta));
    } else if (isInserting) {
      context.missing(_storyIdMeta);
    }
    if (data.containsKey('text_content')) {
      context.handle(
          _textContentMeta,
          textContent.isAcceptableOrUnknown(
              data['text_content']!, _textContentMeta));
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('image_description')) {
      context.handle(
          _imageDescriptionMeta,
          imageDescription.isAcceptableOrUnknown(
              data['image_description']!, _imageDescriptionMeta));
    } else if (isInserting) {
      context.missing(_imageDescriptionMeta);
    }
    if (data.containsKey('background_color')) {
      context.handle(
          _backgroundColorMeta,
          backgroundColor.isAcceptableOrUnknown(
              data['background_color']!, _backgroundColorMeta));
    } else if (isInserting) {
      context.missing(_backgroundColorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoryPageEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoryPageEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      storyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}story_id'])!,
      textContent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_content'])!,
      imageDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}image_description'])!,
      backgroundColor: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}background_color'])!,
    );
  }

  @override
  $StoryPagesTableTable createAlias(String alias) {
    return $StoryPagesTableTable(attachedDatabase, alias);
  }
}

class StoryPageEntity extends DataClass implements Insertable<StoryPageEntity> {
  /// The unique UUID of the page.
  final String id;

  /// Reference to the parent story. Cascade delete will remove pages if the story is deleted.
  final String storyId;

  /// The text content of this page.
  final String textContent;

  /// Description to act as a prompt for image generation, or alt text.
  final String imageDescription;

  /// The background hex color for this page.
  final String backgroundColor;
  const StoryPageEntity(
      {required this.id,
      required this.storyId,
      required this.textContent,
      required this.imageDescription,
      required this.backgroundColor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['story_id'] = Variable<String>(storyId);
    map['text_content'] = Variable<String>(textContent);
    map['image_description'] = Variable<String>(imageDescription);
    map['background_color'] = Variable<String>(backgroundColor);
    return map;
  }

  StoryPagesTableCompanion toCompanion(bool nullToAbsent) {
    return StoryPagesTableCompanion(
      id: Value(id),
      storyId: Value(storyId),
      textContent: Value(textContent),
      imageDescription: Value(imageDescription),
      backgroundColor: Value(backgroundColor),
    );
  }

  factory StoryPageEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoryPageEntity(
      id: serializer.fromJson<String>(json['id']),
      storyId: serializer.fromJson<String>(json['storyId']),
      textContent: serializer.fromJson<String>(json['textContent']),
      imageDescription: serializer.fromJson<String>(json['imageDescription']),
      backgroundColor: serializer.fromJson<String>(json['backgroundColor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storyId': serializer.toJson<String>(storyId),
      'textContent': serializer.toJson<String>(textContent),
      'imageDescription': serializer.toJson<String>(imageDescription),
      'backgroundColor': serializer.toJson<String>(backgroundColor),
    };
  }

  StoryPageEntity copyWith(
          {String? id,
          String? storyId,
          String? textContent,
          String? imageDescription,
          String? backgroundColor}) =>
      StoryPageEntity(
        id: id ?? this.id,
        storyId: storyId ?? this.storyId,
        textContent: textContent ?? this.textContent,
        imageDescription: imageDescription ?? this.imageDescription,
        backgroundColor: backgroundColor ?? this.backgroundColor,
      );
  StoryPageEntity copyWithCompanion(StoryPagesTableCompanion data) {
    return StoryPageEntity(
      id: data.id.present ? data.id.value : this.id,
      storyId: data.storyId.present ? data.storyId.value : this.storyId,
      textContent:
          data.textContent.present ? data.textContent.value : this.textContent,
      imageDescription: data.imageDescription.present
          ? data.imageDescription.value
          : this.imageDescription,
      backgroundColor: data.backgroundColor.present
          ? data.backgroundColor.value
          : this.backgroundColor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoryPageEntity(')
          ..write('id: $id, ')
          ..write('storyId: $storyId, ')
          ..write('textContent: $textContent, ')
          ..write('imageDescription: $imageDescription, ')
          ..write('backgroundColor: $backgroundColor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, storyId, textContent, imageDescription, backgroundColor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoryPageEntity &&
          other.id == this.id &&
          other.storyId == this.storyId &&
          other.textContent == this.textContent &&
          other.imageDescription == this.imageDescription &&
          other.backgroundColor == this.backgroundColor);
}

class StoryPagesTableCompanion extends UpdateCompanion<StoryPageEntity> {
  final Value<String> id;
  final Value<String> storyId;
  final Value<String> textContent;
  final Value<String> imageDescription;
  final Value<String> backgroundColor;
  final Value<int> rowid;
  const StoryPagesTableCompanion({
    this.id = const Value.absent(),
    this.storyId = const Value.absent(),
    this.textContent = const Value.absent(),
    this.imageDescription = const Value.absent(),
    this.backgroundColor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoryPagesTableCompanion.insert({
    required String id,
    required String storyId,
    required String textContent,
    required String imageDescription,
    required String backgroundColor,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        storyId = Value(storyId),
        textContent = Value(textContent),
        imageDescription = Value(imageDescription),
        backgroundColor = Value(backgroundColor);
  static Insertable<StoryPageEntity> custom({
    Expression<String>? id,
    Expression<String>? storyId,
    Expression<String>? textContent,
    Expression<String>? imageDescription,
    Expression<String>? backgroundColor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storyId != null) 'story_id': storyId,
      if (textContent != null) 'text_content': textContent,
      if (imageDescription != null) 'image_description': imageDescription,
      if (backgroundColor != null) 'background_color': backgroundColor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoryPagesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? storyId,
      Value<String>? textContent,
      Value<String>? imageDescription,
      Value<String>? backgroundColor,
      Value<int>? rowid}) {
    return StoryPagesTableCompanion(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      textContent: textContent ?? this.textContent,
      imageDescription: imageDescription ?? this.imageDescription,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storyId.present) {
      map['story_id'] = Variable<String>(storyId.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (imageDescription.present) {
      map['image_description'] = Variable<String>(imageDescription.value);
    }
    if (backgroundColor.present) {
      map['background_color'] = Variable<String>(backgroundColor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoryPagesTableCompanion(')
          ..write('id: $id, ')
          ..write('storyId: $storyId, ')
          ..write('textContent: $textContent, ')
          ..write('imageDescription: $imageDescription, ')
          ..write('backgroundColor: $backgroundColor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SyncQueuesTable syncQueues = $SyncQueuesTable(this);
  late final $StoriesTableTable storiesTable = $StoriesTableTable(this);
  late final $StoryPagesTableTable storyPagesTable =
      $StoryPagesTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [syncQueues, storiesTable, storyPagesTable];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('stories_table',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('story_pages_table', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$SyncQueuesTableCreateCompanionBuilder = SyncQueuesCompanion Function({
  Value<int> id,
  required String actionType,
  required String payload,
  Value<String> status,
  Value<DateTime> createdAt,
});
typedef $$SyncQueuesTableUpdateCompanionBuilder = SyncQueuesCompanion Function({
  Value<int> id,
  Value<String> actionType,
  Value<String> payload,
  Value<String> status,
  Value<DateTime> createdAt,
});

class $$SyncQueuesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueuesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueuesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueuesTable,
    SyncQueue,
    $$SyncQueuesTableFilterComposer,
    $$SyncQueuesTableOrderingComposer,
    $$SyncQueuesTableAnnotationComposer,
    $$SyncQueuesTableCreateCompanionBuilder,
    $$SyncQueuesTableUpdateCompanionBuilder,
    (SyncQueue, BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>),
    SyncQueue,
    PrefetchHooks Function()> {
  $$SyncQueuesTableTableManager(_$AppDatabase db, $SyncQueuesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> actionType = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SyncQueuesCompanion(
            id: id,
            actionType: actionType,
            payload: payload,
            status: status,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String actionType,
            required String payload,
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SyncQueuesCompanion.insert(
            id: id,
            actionType: actionType,
            payload: payload,
            status: status,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueuesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueuesTable,
    SyncQueue,
    $$SyncQueuesTableFilterComposer,
    $$SyncQueuesTableOrderingComposer,
    $$SyncQueuesTableAnnotationComposer,
    $$SyncQueuesTableCreateCompanionBuilder,
    $$SyncQueuesTableUpdateCompanionBuilder,
    (SyncQueue, BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>),
    SyncQueue,
    PrefetchHooks Function()>;
typedef $$StoriesTableTableCreateCompanionBuilder = StoriesTableCompanion
    Function({
  required String id,
  required String title,
  required String coverColor,
  required String coverEmoji,
  Value<bool> isFavorite,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$StoriesTableTableUpdateCompanionBuilder = StoriesTableCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> coverColor,
  Value<String> coverEmoji,
  Value<bool> isFavorite,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$StoriesTableTableReferences
    extends BaseReferences<_$AppDatabase, $StoriesTableTable, StoryEntity> {
  $$StoriesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StoryPagesTableTable, List<StoryPageEntity>>
      _storyPagesTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.storyPagesTable,
              aliasName: $_aliasNameGenerator(
                  db.storiesTable.id, db.storyPagesTable.storyId));

  $$StoryPagesTableTableProcessedTableManager get storyPagesTableRefs {
    final manager =
        $$StoryPagesTableTableTableManager($_db, $_db.storyPagesTable)
            .filter((f) => f.storyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_storyPagesTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$StoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $StoriesTableTable> {
  $$StoriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverColor => $composableBuilder(
      column: $table.coverColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverEmoji => $composableBuilder(
      column: $table.coverEmoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> storyPagesTableRefs(
      Expression<bool> Function($$StoryPagesTableTableFilterComposer f) f) {
    final $$StoryPagesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.storyPagesTable,
        getReferencedColumn: (t) => t.storyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StoryPagesTableTableFilterComposer(
              $db: $db,
              $table: $db.storyPagesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$StoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StoriesTableTable> {
  $$StoriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverColor => $composableBuilder(
      column: $table.coverColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverEmoji => $composableBuilder(
      column: $table.coverEmoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$StoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoriesTableTable> {
  $$StoriesTableTableAnnotationComposer({
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

  GeneratedColumn<String> get coverColor => $composableBuilder(
      column: $table.coverColor, builder: (column) => column);

  GeneratedColumn<String> get coverEmoji => $composableBuilder(
      column: $table.coverEmoji, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> storyPagesTableRefs<T extends Object>(
      Expression<T> Function($$StoryPagesTableTableAnnotationComposer a) f) {
    final $$StoryPagesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.storyPagesTable,
        getReferencedColumn: (t) => t.storyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StoryPagesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.storyPagesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$StoriesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StoriesTableTable,
    StoryEntity,
    $$StoriesTableTableFilterComposer,
    $$StoriesTableTableOrderingComposer,
    $$StoriesTableTableAnnotationComposer,
    $$StoriesTableTableCreateCompanionBuilder,
    $$StoriesTableTableUpdateCompanionBuilder,
    (StoryEntity, $$StoriesTableTableReferences),
    StoryEntity,
    PrefetchHooks Function({bool storyPagesTableRefs})> {
  $$StoriesTableTableTableManager(_$AppDatabase db, $StoriesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> coverColor = const Value.absent(),
            Value<String> coverEmoji = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StoriesTableCompanion(
            id: id,
            title: title,
            coverColor: coverColor,
            coverEmoji: coverEmoji,
            isFavorite: isFavorite,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String coverColor,
            required String coverEmoji,
            Value<bool> isFavorite = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StoriesTableCompanion.insert(
            id: id,
            title: title,
            coverColor: coverColor,
            coverEmoji: coverEmoji,
            isFavorite: isFavorite,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StoriesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({storyPagesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (storyPagesTableRefs) db.storyPagesTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (storyPagesTableRefs)
                    await $_getPrefetchedData<StoryEntity, $StoriesTableTable,
                            StoryPageEntity>(
                        currentTable: table,
                        referencedTable: $$StoriesTableTableReferences
                            ._storyPagesTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$StoriesTableTableReferences(db, table, p0)
                                .storyPagesTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.storyId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$StoriesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StoriesTableTable,
    StoryEntity,
    $$StoriesTableTableFilterComposer,
    $$StoriesTableTableOrderingComposer,
    $$StoriesTableTableAnnotationComposer,
    $$StoriesTableTableCreateCompanionBuilder,
    $$StoriesTableTableUpdateCompanionBuilder,
    (StoryEntity, $$StoriesTableTableReferences),
    StoryEntity,
    PrefetchHooks Function({bool storyPagesTableRefs})>;
typedef $$StoryPagesTableTableCreateCompanionBuilder = StoryPagesTableCompanion
    Function({
  required String id,
  required String storyId,
  required String textContent,
  required String imageDescription,
  required String backgroundColor,
  Value<int> rowid,
});
typedef $$StoryPagesTableTableUpdateCompanionBuilder = StoryPagesTableCompanion
    Function({
  Value<String> id,
  Value<String> storyId,
  Value<String> textContent,
  Value<String> imageDescription,
  Value<String> backgroundColor,
  Value<int> rowid,
});

final class $$StoryPagesTableTableReferences extends BaseReferences<
    _$AppDatabase, $StoryPagesTableTable, StoryPageEntity> {
  $$StoryPagesTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $StoriesTableTable _storyIdTable(_$AppDatabase db) =>
      db.storiesTable.createAlias(
          $_aliasNameGenerator(db.storyPagesTable.storyId, db.storiesTable.id));

  $$StoriesTableTableProcessedTableManager get storyId {
    final $_column = $_itemColumn<String>('story_id')!;

    final manager = $$StoriesTableTableTableManager($_db, $_db.storiesTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_storyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StoryPagesTableTableFilterComposer
    extends Composer<_$AppDatabase, $StoryPagesTableTable> {
  $$StoryPagesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageDescription => $composableBuilder(
      column: $table.imageDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backgroundColor => $composableBuilder(
      column: $table.backgroundColor,
      builder: (column) => ColumnFilters(column));

  $$StoriesTableTableFilterComposer get storyId {
    final $$StoriesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.storyId,
        referencedTable: $db.storiesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StoriesTableTableFilterComposer(
              $db: $db,
              $table: $db.storiesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StoryPagesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StoryPagesTableTable> {
  $$StoryPagesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageDescription => $composableBuilder(
      column: $table.imageDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backgroundColor => $composableBuilder(
      column: $table.backgroundColor,
      builder: (column) => ColumnOrderings(column));

  $$StoriesTableTableOrderingComposer get storyId {
    final $$StoriesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.storyId,
        referencedTable: $db.storiesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StoriesTableTableOrderingComposer(
              $db: $db,
              $table: $db.storiesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StoryPagesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoryPagesTableTable> {
  $$StoryPagesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => column);

  GeneratedColumn<String> get imageDescription => $composableBuilder(
      column: $table.imageDescription, builder: (column) => column);

  GeneratedColumn<String> get backgroundColor => $composableBuilder(
      column: $table.backgroundColor, builder: (column) => column);

  $$StoriesTableTableAnnotationComposer get storyId {
    final $$StoriesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.storyId,
        referencedTable: $db.storiesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StoriesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.storiesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StoryPagesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StoryPagesTableTable,
    StoryPageEntity,
    $$StoryPagesTableTableFilterComposer,
    $$StoryPagesTableTableOrderingComposer,
    $$StoryPagesTableTableAnnotationComposer,
    $$StoryPagesTableTableCreateCompanionBuilder,
    $$StoryPagesTableTableUpdateCompanionBuilder,
    (StoryPageEntity, $$StoryPagesTableTableReferences),
    StoryPageEntity,
    PrefetchHooks Function({bool storyId})> {
  $$StoryPagesTableTableTableManager(
      _$AppDatabase db, $StoryPagesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoryPagesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoryPagesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoryPagesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> storyId = const Value.absent(),
            Value<String> textContent = const Value.absent(),
            Value<String> imageDescription = const Value.absent(),
            Value<String> backgroundColor = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StoryPagesTableCompanion(
            id: id,
            storyId: storyId,
            textContent: textContent,
            imageDescription: imageDescription,
            backgroundColor: backgroundColor,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String storyId,
            required String textContent,
            required String imageDescription,
            required String backgroundColor,
            Value<int> rowid = const Value.absent(),
          }) =>
              StoryPagesTableCompanion.insert(
            id: id,
            storyId: storyId,
            textContent: textContent,
            imageDescription: imageDescription,
            backgroundColor: backgroundColor,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StoryPagesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({storyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (storyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.storyId,
                    referencedTable:
                        $$StoryPagesTableTableReferences._storyIdTable(db),
                    referencedColumn:
                        $$StoryPagesTableTableReferences._storyIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StoryPagesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StoryPagesTableTable,
    StoryPageEntity,
    $$StoryPagesTableTableFilterComposer,
    $$StoryPagesTableTableOrderingComposer,
    $$StoryPagesTableTableAnnotationComposer,
    $$StoryPagesTableTableCreateCompanionBuilder,
    $$StoryPagesTableTableUpdateCompanionBuilder,
    (StoryPageEntity, $$StoryPagesTableTableReferences),
    StoryPageEntity,
    PrefetchHooks Function({bool storyId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SyncQueuesTableTableManager get syncQueues =>
      $$SyncQueuesTableTableManager(_db, _db.syncQueues);
  $$StoriesTableTableTableManager get storiesTable =>
      $$StoriesTableTableTableManager(_db, _db.storiesTable);
  $$StoryPagesTableTableTableManager get storyPagesTable =>
      $$StoryPagesTableTableTableManager(_db, _db.storyPagesTable);
}
