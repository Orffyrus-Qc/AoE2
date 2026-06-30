"""Create a one-click 1v1 test scenario with AdaptiveAI pre-configured."""
from __future__ import annotations

import os

from AoE2ScenarioParser.datasets.object_support import Civilization, StartingAge
from AoE2ScenarioParser.datasets.players import PlayerId
from AoE2ScenarioParser.datasets.trigger_lists import DiplomacyState, VictoryCondition
from AoE2ScenarioParser.scenarios.aoe2_de_scenario import AoE2DEScenario

STEAM_ID = "76561198311478416"
SCENARIO_NAME = "AdaptiveAI 1v1 Test.aoe2scenario"


def scenario_output_paths() -> list[str]:
    base = os.path.join(os.environ["USERPROFILE"], "Games", "Age of Empires 2 DE")
    paths = [
        os.path.join(base, "resources", "_common", "scenario", SCENARIO_NAME),
        os.path.join(base, STEAM_ID, "resources", "_common", "scenario", SCENARIO_NAME),
    ]
    return paths


def build_scenario() -> AoE2DEScenario:
    scenario = AoE2DEScenario.from_default()
    player_manager = scenario.player_manager
    option_manager = scenario.option_manager
    message_manager = scenario.message_manager
    map_manager = scenario.map_manager

    player_manager.active_players = 2

    player_one = player_manager.players[PlayerId.ONE]
    player_two = player_manager.players[PlayerId.TWO]

    player_one.human = True
    player_one.civilization = Civilization.FRANKS
    player_one.lock_civ = True

    player_two.human = False
    player_two.civilization = Civilization.BRITONS
    player_two.tribe_name = "AdaptiveAI"
    player_two.lock_personality = True
    player_two.lock_civ = True

    player_one.set_player_diplomacy(PlayerId.TWO, DiplomacyState.ENEMY)
    player_two.set_player_diplomacy(PlayerId.ONE, DiplomacyState.ENEMY)

    player_manager.set_default_starting_resources([PlayerId.ONE, PlayerId.TWO])
    for player in (player_one, player_two):
        player.starting_age = StartingAge.DARK_AGE
        player.population_cap = 200

    option_manager.victory_condition = VictoryCondition.STANDARD
    option_manager.lock_teams = True
    option_manager.allow_players_choose_teams = False

    map_manager.map_size = 200

    message_manager.instructions = (
        "AdaptiveAI 1v1 Test\n\n"
        "You vs AdaptiveAI (Extreme-style economy + adaptive counters).\n"
        "Try drush, scout rush, archer rush, or fast castle.\n"
        "Watch in-game chat for: AdaptiveAI: Detected ..."
    )
    message_manager.hints = (
        "Optional: open this scenario in the editor, Map tab -> Random Map -> Arabia, "
        "generate once, then re-save. Or play as-is on the default map for quick tests."
    )

    scenario.sections["FileHeader"].instructions = (
        "1v1 AdaptiveAI test scenario. Player 2 personality is locked to AdaptiveAI."
    )

    return scenario


def main() -> None:
    scenario = build_scenario()
    for path in scenario_output_paths():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        scenario.write_to_file(path)
        print(f"Wrote: {path}")


if __name__ == "__main__":
    main()