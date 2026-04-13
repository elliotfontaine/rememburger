class_name AudioBanks
extends Node
## Define new audio tracks in [_init_resonate_audio_banks] and play them via [AudioManagerWrapper].
## [br][br]
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

const MUSIC_BANK: String = "music"
const SOUND_BANK: String = "sfx"

@export var music_bank_bus: String = "Music"
@export var sound_bank_bus: String = "SFX"

@onready var music_bank: MusicBank = $MusicBank
@onready var sound_bank: SoundBank = $SoundBank


func _ready() -> void:
	_init_resonate_audio_banks()


func _init_resonate_audio_banks() -> void:
	music_bank.label = MUSIC_BANK
	sound_bank.label = SOUND_BANK

	music_bank.bus = music_bank_bus
	sound_bank.bus = sound_bank_bus

	var music_tracks: Array[MusicTrackResource] = []
	music_tracks.append(_init_music(AssetReference.MENU_DOODLE_2_LOOP, AudioEnum.Music.MENU_DOODLE))
	music_bank.tracks = music_tracks

	var sound_tracks: Array[SoundEventResource] = []
	sound_tracks.append(_init_sound(AssetReference.CLICK_4, AudioEnum.Sfx.CLICK))
	sound_tracks.append(_init_sound(AssetReference.CLICK_5, AudioEnum.Sfx.SELECT))
	sound_tracks.append(_init_sound(AssetReference.MOUSECLICK_1, AudioEnum.Sfx.SELECT_2))
	sound_tracks.append(_init_sound(AssetReference.MOUSERELEASE_1, AudioEnum.Sfx.CLICK_2))
	sound_tracks.append(_init_sound(AssetReference.DING_2, AudioEnum.Sfx.GAME_OVER))
	sound_tracks.append(_init_sound(AssetReference.DING_3, AudioEnum.Sfx.CLIENT_ENTER))
	sound_tracks.append(_init_sound(AssetReference.DOOR_KNOCK_1, AudioEnum.Sfx.CUTTING_BOARD_1))
	sound_tracks.append(_init_sound(AssetReference.DOOR_KNOCK_2, AudioEnum.Sfx.CUTTING_BOARD_2))
	sound_tracks.append(_init_sound(AssetReference.DOOR_KNOCK_3, AudioEnum.Sfx.CUTTING_BOARD_3))
	sound_tracks.append(_init_sound(AssetReference.DOOR_KNOCK_OFFICE, AudioEnum.Sfx.CUTTING_BOARD_4))
	sound_tracks.append(_init_sound(AssetReference.SPLAT_1, AudioEnum.Sfx.SAUCE))
	sound_tracks.append(_init_sound(AssetReference.KNIFE_7, AudioEnum.Sfx.KNIFE))
	sound_tracks.append(_init_sound(AssetReference.PLATE_TAKE_OFF_SHELF_1, AudioEnum.Sfx.PLATE_1))
	sound_bank.events = sound_tracks


func _init_music(audio_stream: AudioStream, music: AudioEnum.Music) -> MusicTrackResource:
	var music_name: String = EnumUtils.to_name(music, AudioEnum.Music)
	var music_stem: MusicStemResource = _create_music_stem(audio_stream)
	var music_stems: Array[MusicStemResource] = []
	music_stems.append(music_stem)
	return _create_music_track(music_name, music_stems)


func _init_sound(audio_stream: AudioStream, sound: AudioEnum.Sfx) -> SoundEventResource:
	var sound_name: String = EnumUtils.to_name(sound, AudioEnum.Sfx)
	var audio_streams: Array[AudioStream] = []
	audio_streams.append(audio_stream)
	return _create_sound_event(sound_name, audio_streams)


func _create_music_stem(stream: AudioStream) -> MusicStemResource:
	var stem: MusicStemResource = MusicStemResource.new()
	stem.enabled = true
	stem.stream = stream
	return stem


func _create_music_track(
	track_name: String, stems: Array[MusicStemResource], bus: String = music_bank_bus
) -> MusicTrackResource:
	var track: MusicTrackResource = MusicTrackResource.new()
	track.name = track_name
	track.bus = bus
	track.stems = stems
	return track


func _create_sound_event(
	sound_name: String, streams: Array[AudioStream], bus: String = sound_bank_bus
) -> SoundEventResource:
	var event: SoundEventResource = SoundEventResource.new()
	event.name = sound_name
	event.bus = bus
	event.streams = streams
	return event
