SMODS.Atlas {
    key = 'Joker',
    path = 'jokers.png',
    px = 71,
    py = 95
}

SMODS.Atlas {
    key = 'placeholder',
    path = 'glorp.png',
    px = 71,
    py = 95
}

local ease_dollars_ref = ease_dollars
function ease_dollars(mod)
    ease_dollars_ref(mod)
    SMODS.calculate_context { money_changed = mod }
end

--Furina
SMODS.Joker {
    key = 'j_furina',
    loc_txt = {
        name = "Shower me with praise!",
        text = {
            "{C:red}-$#5#{} every hand played",
            "Gains {X:mult,C:white} X#4# {} Mult for every",
            "{C:money}$#1#{} {C:inactive}[#2#]{} gained or lost",
            "{C:inactive}(Currently {X:mult,C:white} X#3# {} {C:inactive}Mult){}"
        }
    },

    rarity = 3,
    atlas = 'Joker',
    pos = { x = 4, y = 0 },
    cost = 9,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { req_change = 13, current_count = 0, Xmult = 1, Xmult_inc = 0.1, cost = -2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.req_change, card.ability.extra.req_change - card.ability.extra.current_count, card.ability.extra.Xmult, card.ability.extra.Xmult_inc, card.ability.extra.cost * -1 } }
    end,

    calculate = function(self, card, context)
        if context.before then
            ease_dollars(card.ability.extra.cost)
            return {
                message = '-$' .. number_format(card.ability.extra.cost * -1),
                colour = G.C.MULT,
                card = card
            }
        end

        if context.money_changed and not context.blueprint then
            card.ability.extra.current_count = card.ability.extra.current_count + math.sqrt(context.money_changed ^ 2)

            while card.ability.extra.current_count >= card.ability.extra.req_change do
                card.ability.extra.current_count = card.ability.extra.current_count - card.ability.extra.req_change

                card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_inc
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    { message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } } })
            end
        end

        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult,
                card = card
            }
        end
    end
}

--Neuvi
SMODS.Joker {
    key = 'j_neuvillette',
    loc_txt = {
        name = "Settle down!",
        text = {
            "{C:red}-$#2#{} when leaving",
            "the shop, {C:money}+$#1#{} at",
            "the end of the round",
        }
    },

    rarity = 1,
    atlas = 'Joker',
    pos = { x = 6, y = 0 },
    cost = 6,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { gain = 20, loss = 14 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.gain, card.ability.extra.loss } }
    end,

    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            ease_dollars(card.ability.extra.loss * -1)
            return {
                message = '-$' .. number_format(card.ability.extra.loss),
                colour = G.C.MULT,
                card = card
            }
        end
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.gain
    end
}

--Hyacine
SMODS.Joker {
    key = 'j_hyacine',
    loc_txt = {
        name = "Have some sunshine!",
        text = {
            "{C:money}+$#1#{} anytime",
            "money is lost"
        }
    },

    rarity = 2,
    atlas = 'Joker',
    pos = { x = 2, y = 1 },
    cost = 7,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { money = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money } }
    end,

    calculate = function(self, card, context)
        if context.money_changed then
            if context.money_changed < 0 then
                ease_dollars(card.ability.extra.money)
                card:juice_up(0.3, 0.4)
            end
        end
    end
}

local rcc = reset_castle_card
function reset_castle_card()
    rcc()
    G.GAME.current_round.ajaw_suit = "Spades"
    G.GAME.current_round.asta_suit = "Hearts"
    local valid_castle_cards = {}
    for k, v in ipairs(G.playing_cards) do
        if not SMODS.has_no_suit(v) then
            valid_castle_cards[#valid_castle_cards + 1] = v
        end
    end

    if valid_castle_cards[1] then
        local ajaw_card = pseudorandom_element(valid_castle_cards)
        G.GAME.current_round.ajaw_suit = ajaw_card.base.suit

        local asta_card = pseudorandom_element(valid_castle_cards)
        G.GAME.current_round.asta_suit = asta_card.base.suit
    end
end

--Ajaw
SMODS.Joker {
    key = 'j_ajaw',
    loc_txt = {
        name = "Almighty Ku'hul Ajaw",
        text = {
            "After discarding {C:attention}#2#{} {C:inactive}[#3#]",
            "{V:1}#1#{} cards, {X:mult,C:white} X#4# {} Mult",
            "for the next hand.",
            "Suit changes each round"
        }
    },
    rarity = 2,
    atlas = 'Joker',
    pos = { x = 3, y = 0 },
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { Xmult = 3, discard_req = 4, current_stacks = 0 } },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                localize(G.GAME.current_round.ajaw_suit or "Spades",
                    "suits_singular"),
                card.ability.extra.discard_req,
                card.ability.extra.current_stacks,
                card.ability.extra.Xmult,
                colours = { G.C.SUITS[G.GAME.current_round.ajaw_suit or "Spades"] }
            }
        }
    end,

    calculate = function(self, card, context)
        if context.discard and context.other_card:is_suit(G.GAME.current_round.ajaw_suit) and not context.blueprint then
            local eval = function() return card.ability.extra.current_stacks >= card.ability.extra.discard_req end
            juice_card_until(card, eval, true)
            card.ability.extra.current_stacks = card.ability.extra.current_stacks + 1
            if card.ability.extra.current_stacks == card.ability.extra.discard_req then
                return {
                    message = "Activated",
                    colour = G.C.FILTER,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.current_stacks >= card.ability.extra.discard_req then
                return {
                    Xmult = card.ability.extra.Xmult,
                    card = card
                }
            end
        end

        if context.after and card.ability.extra.current_stacks >= card.ability.extra.discard_req then
            card.ability.extra.current_stacks = 0
        end
    end
}

--Nilou
SMODS.Joker {
    key = 'j_nilou',
    loc_txt = {
        name = "Dance with the waves!",
        text = {
            "Gains {C:chips}+#1#{} Chips when played",
            "hand has at least {C:attention}4{} scoring cards",
            "and exactly {C:attention}2{} different {C:attention}suits{}",
            "{C:inactive}[currently {C:chips}+#2#{} {C:inactive}chips]"
        }
    },

    rarity = 1,
    atlas = 'Joker',
    pos = { x = 5, y = 0 },
    cost = 5,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { chips_mod = 25, chips = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips_mod, card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint and #context.scoring_hand >= 4 then
            local suits = {
                ['Hearts'] = 0,
                ['Diamonds'] = 0,
                ['Spades'] = 0,
                ['Clubs'] = 0
            }
            local suitcount = 0
            local wilds = 0
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i].ability.name == 'Wild Card' then
                    wilds = wilds + 1
                elseif context.scoring_hand[i]:is_suit('Spades', true) then
                    if suits["Spades"] == 0 then
                        suits["Spades"] = suits["Spades"] + 1
                        suitcount = suitcount + 1
                    end
                elseif context.scoring_hand[i]:is_suit('Hearts', true) then
                    if suits["Hearts"] == 0 then
                        suits["Hearts"] = suits["Hearts"] + 1
                        suitcount = suitcount + 1
                    end
                elseif context.scoring_hand[i]:is_suit('Clubs', true) then
                    if suits["Clubs"] == 0 then
                        suits["Clubs"] = suits["Clubs"] + 1
                        suitcount = suitcount + 1
                    end
                elseif context.scoring_hand[i]:is_suit('Diamonds', true) then
                    if suits["Diamonds"] == 0 then
                        suits["Diamonds"] = suits["Diamonds"] + 1
                        suitcount = suitcount + 1
                    end
                end
            end

            if suitcount == 2 or (suitcount < 2 and wilds > 0) then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_mod

                card_eval_status_text(card, "extra", nil, nil, nil, {
                    message = localize({
                        type = "variable",
                        key = "a_chips",
                        vars = { number_format(card.ability.extra.chips) },
                    }),
                    colour = G.C.CHIPS,
                })
            end
        end
        if context.joker_main and card.ability.extra.chips > 0 then
            return {
                chips = card.ability.extra.chips,
                card = card
            }
        end
    end
}

--Sucrose
SMODS.Joker {
    key = 'j_sucrose',
    loc_txt = {
        name = "Anemo test 6308!",
        text = {
            "If played hand contains only {C:attention}1{}",
            "{C:attention}scoring{} card, all played cards of",
            "the corresponding {C:attention}suit{} will",
            "give {X:mult,C:white} X#1# {} Mult when scored",
            "for the next played hand",
            "{C:inactive}[currently: #2#]{}"
        }
    },
    rarity = 3,
    atlas = 'Joker',
    pos = { x = 0, y = 0 },
    cost = 7,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { Xmult = 1.5, suit = "none" } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult, card.ability.extra.suit } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint and #context.scoring_hand == 1 then
            return { message = "swirl", colour = G.C.GREEN, card = card }
        end

        if context.after and not context.blueprint and #context.scoring_hand == 1 then
            local rejuice = true
            if card.ability.extra.suit ~= "none" then
                rejuice = false
            end
            if context.scoring_hand[1].ability.name == 'Wild Card' then
                card.ability.extra.suit = 'all'
            elseif context.scoring_hand[1]:is_suit('Spades', true) then
                card.ability.extra.suit = 'Spades'
            elseif context.scoring_hand[1]:is_suit('Hearts', true) then
                card.ability.extra.suit = 'Hearts'
            elseif context.scoring_hand[1]:is_suit('Clubs', true) then
                card.ability.extra.suit = 'Clubs'
            elseif context.scoring_hand[1]:is_suit('Diamonds', true) then
                card.ability.extra.suit = 'Diamonds'
            end

            if rejuice then
                local eval = function() return card.ability.extra.suit ~= "none" end
                juice_card_until(card, eval, true)
            end
        end

        if context.after and not context.blueprint and #context.scoring_hand ~= 1 then
            card.ability.extra.suit = "none"
        end

        if context.individual and context.cardarea == G.play then
            if card.ability.extra.suit ~= "none" then
                if card.ability.extra.suit == "all" or context.other_card.ability.name == 'Wild Card' or context.other_card:is_suit(card.ability.extra.suit, true) then
                    return {
                        x_mult = card.ability.extra.Xmult,
                        colour = G.C.RED,
                        card = card,
                    }
                end
            end
        end
    end
}

--Hu Tao
SMODS.Joker {
    key = 'j_hutao',
    loc_txt = {
        name = "Pyre, pyre, pants on fire!",
        text = {
            "{X:mult,C:white} X#1# {} Mult when 2",
            "or less hands remaining"
        }
    },

    rarity = 1,
    atlas = 'Joker',
    pos = { x = 2, y = 0 },
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { Xmult = 1.75 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and G.GAME.current_round.hands_left <= 1 then
            return {
                Xmult = card.ability.extra.Xmult,
                card = card
            }
        end
    end
}

--Yanfei
SMODS.Joker {
    key = 'j_yanfei',
    loc_txt = {
        name = "Wrath of the flame!",
        text = {
            "After playing {C:attention}#2#{} hands,",
            "gain {C:chips}+#4#{} hand and {X:mult,C:white} X#1# {} Mult",
            "for the next played hand",
            "{C:inactive}#3# remaining{}"
        }
    },
    rarity = 2,
    atlas = 'Joker',
    pos = { x = 1, y = 0 },
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { Xmult = 2, hand_req = 4, hands_left = 4, hands_bonus = 1 } },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.Xmult,
                card.ability.extra.hand_req,
                card.ability.extra.hands_left,
                card.ability.extra.hands_bonus }
        }
    end,

    calculate = function(self, card, context)
        if context.after then
            local reset = false
            if card.ability.extra.hands_left == 0 then
                card.ability.extra.hands_left = card.ability.extra.hand_req
                reset = true
            end

            if not context.blueprint and not reset then
                card.ability.extra.hands_left = card.ability.extra.hands_left - 1
            end

            if card.ability.extra.hands_left == 0 then
                ease_hands_played(card.ability.extra.hands_bonus)
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                    { message = localize { type = 'variable', key = 'a_hands', vars = { card.ability.extra.hands_bonus } } })
                local eval = function() return card.ability.extra.hands_left == 0 end
                juice_card_until(card, eval, true)
            end
        end

        if context.joker_main then
            if card.ability.extra.hands_left == 0 then
                return {
                    Xmult = card.ability.extra.Xmult,
                    card = card
                }
            end
        end
    end
}

SMODS.ObjectType({
    key = "Suiter",
    default = "c_sun",
    cards = {},
    inject = function(self)
        SMODS.ObjectType.inject(self)
        self:inject_card(G.P_CENTERS.c_world)
        self:inject_card(G.P_CENTERS.c_sun)
        self:inject_card(G.P_CENTERS.c_moon)
        self:inject_card(G.P_CENTERS.c_star)
        self:inject_card(G.P_CENTERS.c_lovers)
    end,
})

--Jahoda
SMODS.Joker {
    key = 'j_jahoda',
    loc_txt = {
        name = "Finders keepers!",
        text = {
            "Randomly creates a {C:attention}Suit changing{}",
            "{C:attention}Tarot{} or {C:attention}The lovers{} if played hand",
            "contains at least {C:attention}4 scoring{} cards.",
            "{C:inactive}(Must have room){}"
        }
    },

    rarity = 2,
    atlas = 'Joker',
    pos = { x = 6, y = 2 },
    cost = 7,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    calculate = function(self, card, context)
        if context.before and #context.scoring_hand >= 4
            and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = (function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local card = create_card('Suiter', G.consumeables, nil, nil, nil, nil, nil, 'jahoda')
                            card:add_to_deck()
                            G.consumeables:emplace(card)
                            G.GAME.consumeable_buffer = 0
                            return true
                        end
                    }))
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                        { message = localize('k_plus_tarot'), colour = G.C.PURPLE })
                    return true
                end)
            }))
        end
    end
}

--Venti
SMODS.Joker {
    key = 'j_venti',
    loc_txt = {
        name = "Time for takeoff!",
        text = {
            "During {C:attention}first hand{} of the round,",
            "convert {C:attention}all cards{} to",
            "the suit of the {C:attention}first scoring card{}"
        }
    },

    rarity = 2,
    atlas = 'Joker',
    pos = { x = 1, y = 1 },
    cost = 7,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local eval = function() return G.GAME.current_round.hands_played == 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end
        if context.before and G.GAME.current_round.hands_played == 0 then
            local suit = context.scoring_hand[1].base.suit
            for k, v in ipairs(context.full_hand) do
                G.E_MANAGER:add_event(Event({
                    func = function()
                        SMODS.change_base(v, suit)
                        v:juice_up()
                        return true
                    end
                }))
            end     
            return {
                message = 'Swirl!',
                colour = G.C.GREEN,
                card = card
            }
        end
    end
}

--Escoffier
SMODS.Joker {
    key = 'j_escoffier',
    loc_txt = {
        name = "Goose on the loose!",
        text = {
            "If {C:attention}poker hand{} contains 2/3/4/5",
            "{C:diamonds}Diamond{} or {C:clubs}Club{} cards, this joker",
            "gains {C:mult}+#1#{}/{C:mult}+#2#{}/{C:mult}+#2#{}/{C:mult}+#3#{} Mult",
            "{C:inactive}[currently {C:mult}+#4#{} {C:inactive}Mult]"
        }
    },

    rarity = 1,
    atlas = 'Joker',
    pos = { x = 0, y = 1 },
    cost = 5,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { extra_mult_1 = 1, extra_mult_2 = 2, extra_mult_3 = 3, mult = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.extra_mult_1, card.ability.extra.extra_mult_2, card.ability.extra.extra_mult_3, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local cardcount = 0
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i].ability.name == 'Wild Card' or context.scoring_hand[i]:is_suit('Diamonds', true) or context.scoring_hand[i]:is_suit('Clubs', true) then
                    cardcount = cardcount + 1
                end
            end

            if cardcount == 2 then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.extra_mult_1
            elseif cardcount == 3 or cardcount == 4 then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.extra_mult_2
            elseif cardcount == 5 then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.extra_mult_3
            end

            if cardcount > 1 then
                card_eval_status_text(card, "extra", nil, nil, nil, { message = localize('k_upgrade_ex') })
            end
        end

        if context.joker_main and (card.ability.extra.mult > 0) then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

--Chevreuse
SMODS.Joker {
    key = 'j_chevreuse',
    loc_txt = {
        name = "Drop your weapons!",
        text = {
            "{X:mult,C:white} X#1# {} Mult if {C:attention}scoring hand{} contains ",
            "only {C:hearts}Heart{} and {C:spades}Spade{} cards, and ",
            "contains at least one of each"
        }
    },

    rarity = 2,
    atlas = 'Joker',
    pos = { x = 0, y = 3 },
    cost = 5,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { Xmult = 3 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local hearts = 0
            local spades = 0
            local wilds = 0
            local wrong = 0
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i].ability.name == 'Wild Card' then
                    wilds = wilds + 1
                elseif context.scoring_hand[i]:is_suit('Spades', true) then
                    spades = 1
                elseif context.scoring_hand[i]:is_suit('Hearts', true) then
                    hearts = 1
                elseif context.scoring_hand[i]:is_suit('Clubs', true) or context.scoring_hand[i]:is_suit('Diamonds', true) then
                    wrong = 1
                end
            end

            if hearts + spades + wilds >= 2 and wrong == 0 then
                return {
                    Xmult = card.ability.extra.Xmult
                }
            end
        end
    end
}

--Herta
SMODS.Joker {
    key = 'j_herta',
    loc_txt = {
        name = "Nothing but a void!",
        text = {
            "For every {C:attention}scoring card{} played,",
            "this joker gains {X:mult,C:white} X#1# {} Mult for",
            "the {C:attention}final hand{} of the round",
            "{C:inactive}(currently {}{X:mult,C:white} X#2# {} {C:inactive}Mult){}"
        }
    },

    rarity = 2,
    atlas = 'Joker',
    pos = { x = 4, y = 1 },
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { Xmult_mod = 0.25, Xmult = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            for i = 1, #context.scoring_hand do
                card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
            end
            card_eval_status_text(card, 'extra', nil, nil, nil,
                { message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } } })
        end

        if context.joker_main and G.GAME.current_round.hands_left == 0 then
            return {
                Xmult = card.ability.extra.Xmult,
                card = card
            }
        end

        if context.end_of_round and context.cardarea == G.jokers then
            card.ability.extra.Xmult = 1
        end
    end
}

--Tribbie
SMODS.Joker {
    key = 'j_tribbie',
    loc_txt = {
        name = "Away we go!",
        text = {
            "Gives {C:chips}+#1#{} chips for",
            "every card in played",
            "{C:attention}poker hand{}"
        }
    },

    rarity = 1,
    atlas = 'Joker',
    pos = { x = 6, y = 1 },
    cost = 7,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { chips = 25 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            this_hand_chips = card.ability.extra.chips * #context.scoring_hand
            return {
                chips = this_hand_chips,
                card = card
            }
        end
    end
}

--Freminet
SMODS.Joker {
    key = 'j_freminet',
    loc_txt = {
        name = "Pers!",
        text = {
            "{C:chips}+#1#{} chips and {C:mult}+#2#{} Mult.",
            "{C:chips}-#3#{} chips and {C:mult}+#4#{} mult after every",
            "hand played, resets each round",
        }
    },

    rarity = 1,
    atlas = 'Joker',
    pos = { x = 1, y = 4 },
    cost = 4,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { chips = 60, mult = 0, chips_loss = 15, mult_gain = 4, init_chips = 80 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.mult, card.ability.extra.chips_loss, card.ability.extra.mult_gain} }
    end,

    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips - card.ability.extra.chips_loss
            if card.ability.extra.chips < 0 then
                card.ability.extra.chips = 0
            end
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            card_eval_status_text(card, 'extra', nil, nil, nil,
                { message = "pressure up!" })
        end

        if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.init_chips
            card.ability.extra.mult = 0
            return {
                message = localize('k_reset'),
                colour = G.C.RED
            }
        end

        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
                mult = card.ability.extra.mult,
                card = card
            }
        end
    end
}

--Durin
SMODS.Joker {
    key = 'j_durin',
    loc_txt = {
        name = "A turning point, in fate!",
        text = {
            "{C:money}+$#1#{} if poker hand is a",
            "{C:attention}Three of a kind{} or lower,",
            "{X:mult,C:white} X#2# {} Mult If poker hand is a",
            "{C:attention}Straight{} or higher"
        }
    },

    rarity = 3,
    atlas = 'Joker',
    pos = { x = 3, y = 1 },
    cost = 7,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { money = 3, Xmult = 2.5 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.before and not next(context.poker_hands["Flush"]) and not next(context.poker_hands["Straight"]) and not next(context.poker_hands["Full House"]) and not next(context.poker_hands["Four of a Kind"]) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    card.children.center:set_sprite_pos{ x = 7, y = 3 }
                    return true
                end
            }))
            ease_dollars(card.ability.extra.money)
            return {
                message = "$" .. number_format(card.ability.extra.money),
                colour = G.C.MONEY,
                card = card
            }
        end

        if context.joker_main and (next(context.poker_hands["Flush"]) or next(context.poker_hands["Straight"]) or next(context.poker_hands["Full House"]) or next(context.poker_hands["Four of a Kind"])) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    card.children.center:set_sprite_pos{ x = 3, y = 1 }
                    return true
                end
            }))
            return {
                Xmult = card.ability.extra.Xmult,
                card = card
            }
        end
    end
}

--Castorice
SMODS.Joker {
    key = 'j_cassie',
    loc_txt = {
        name = "Return to dust!",
        text = {
            "If you run out hands, gain",
            "{C:chips}+#1#{} Hand and {C:mult}lose $#3#{},",
            "Cost gets {C:attention}doubled{} for every",
            "consecutive trigger this round",
            "{C:inactive}(Must have enough Money){}"
        }
    },

    rarity = 2,
    atlas = 'Joker',
    pos = { x = 5, y = 1 },
    cost = 7,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { extra_hands = 1, base_cost = 5, cost = 5 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.extra_hands, card.ability.extra.base_cost, card.ability.extra.cost } }
    end,

    calculate = function(self, card, context)
        if context.after and G.GAME.current_round.hands_left == 0 and G.GAME.dollars >= card.ability.extra.cost and G.GAME.chips + hand_chips * mult < G.GAME.blind.chips then
            ease_hands_played(card.ability.extra.extra_hands)
            ease_dollars(card.ability.extra.cost * -1)
            card.ability.extra.cost = card.ability.extra.cost * 2
            return {
                message = '-$' .. number_format(card.ability.extra.cost / 2),
                colour = G.C.MULT
            }
        end

        if context.end_of_round and context.cardarea == G.jokers then
            card.ability.extra.cost = card.ability.extra.base_cost
        end
    end
}

--Iansas
SMODS.Joker {
    key = 'j_iansan',
    loc_txt = {
        name = "Start the clock!",
        text = {
            "Gains {X:mult,C:white} X#1# {} Mult if played {C:attention}poker hand{}",
            "is different from the last played hand.",
            "Resets when {C:attention}Boss Blind{} is defeated, or",
            "when playing the same hand twice is a row",
            "{C:inactive}(currently {}{X:mult,C:white} X#2# {} {C:inactive}Mult){}",
            "{C:inactive}last played hand: {}{C:attention}#3#{}",
        }
    },

    rarity = 2,
    atlas = 'Joker',
    pos = { x = 0, y = 4 },
    cost = 7,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { Xmult_mod = 0.25, Xmult = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult, G.GAME.last_hand_played } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if G.GAME.last_hand_played == context.scoring_name then
                card.ability.extra.Xmult = 1
                return {
                    message = localize('k_reset'),
                    colour = G.C.RED
                }
            else
                card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    { message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } } })
            end
        end

        if context.joker_main and card.ability.extra.Xmult > 1 then
            return {
                Xmult = card.ability.extra.Xmult,
                card = card
            }
        end

        if context.beat_boss and context.cardarea == G.jokers  and card.ability.extra.Xmult > 1 then
            card.ability.extra.Xmult = 1
            return {
                message = localize('k_reset'),
                colour = G.C.RED
            }
        end
    end
}

--Cyrene
SMODS.Joker {
    key = 'j_Elysia',
    loc_txt = {
        name = "It's Elysin' time!",
        text = {
            "#1#",
            "{X:mult,C:white} X#3# {} Mult",
            "#2#"
        }
    },
    rarity = 3,
    atlas = 'Joker',
    pos = { x = 3, y = 2 },
    cost = 7,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { display_text = "Still charging ult...", display_text2 = "(surely she gets it soon)", Xmult = 1.5, low_Xmult = 1.5, fake_Xmult = 10 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.display_text, card.ability.extra.display_text2, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.cardarea == G.jokers then
            card.ability.extra.display_text = "Ult is ready!"
            card.ability.extra.Xmult = card.ability.extra.fake_Xmult
            card.ability.extra.display_text2 = "Until the next round starts"
            return {
                message = "Ult ready!",
                colour = G.C.PINK,
                card = card
            }
        end

        if context.setting_blind then
            card.ability.extra.display_text = "Still charging ult..."
            card.ability.extra.Xmult = card.ability.extra.low_Xmult
            card.ability.extra.display_text2 = "(surely she gets it soon)"
        end

        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult,
                card = card
            }
        end
    end
}

--Cipher
SMODS.Joker {
    key = 'j_cipher',
    loc_txt = {
        name = "Our cute play session is over!",
        text = {
            "Stores {X:mult,C:white} X#1# {} Mult every hand.",
            "Gives {C:mult}Stored Mult{} and resets",
            "when in the {C:attention}rightmost position{}",
            "{C:inactive}(currently {}{X:mult,C:white} X#2# {} {C:inactive}Mult){}"
        }
    },

    rarity = 3,
    atlas = 'Joker',
    pos = { x = 2, y = 2 },
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { Xmult_mod = 0.3, Xmult = 1, used = false } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
            card_eval_status_text(card, 'extra', nil, nil, nil,
                { message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } } })
        end

        if context.joker_main and G.jokers.cards[#G.jokers.cards] == card then
            card.ability.extra.used = true
            return {
                Xmult = card.ability.extra.Xmult,
                card = card
            }
        end

        -- if context.joker_main and G.jokers.cards[#G.jokers.cards] ~= card and not context.blueprint then
        --     card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
        --     card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra.Xmult}}})
        -- end

        if context.after and card.ability.extra.used then
            card.ability.extra.Xmult = 1
            card.ability.extra.used = false
        end
    end
}

--Navia
SMODS.Joker {
    key = 'j_navia',
    loc_txt = {
        name = "A proper sendoff!",
        text = {
            "Gains {X:mult,C:white} X#1# {} Mult for",
            "every {C:attention}Stone card{} played.",
            "Destroys all played {C:attention}Stone cards{}",
            "{C:inactive}(currently {}{X:mult,C:white} X#2# {} {C:inactive}Mult){}"
        }
    },

    rarity = 3,
    atlas = 'Joker',
    pos = { x = 0, y = 2 },
    cost = 7,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { Xmult_mod = 0.75, Xmult = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card.ability.effect == 'Stone Card' and not context.blueprint then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
            card_eval_status_text(card, 'extra', nil, nil, nil, { message = localize('k_upgrade_ex') })
        end

        if context.destroy_card and (context.cardarea == G.play or context.cardarea == "unscored") and not context.blueprint then
            if context.destroy_card.ability.effect == 'Stone Card' then
                return {
                    remove = not SMODS.is_eternal(context.destroy_card),
                    card = card
                }
            end
        end

        if context.joker_main and card.ability.extra.Xmult > 1 then
            return {
                Xmult = card.ability.extra.Xmult,
                card = card
            }
        end
    end
}

--Kachina
SMODS.Joker {
    key = 'j_kachina',
    loc_txt = {
        name = "Drilling down!",
        text = {
            "Creates and places a",
            "{C:attention}Stone card{} into every",
            "{C:attention}played hand{}",
            "{C:inactive}(Must have room){}"
        }
    },

    rarity = 2,
    atlas = 'Joker',
    pos = { x = 1, y = 2 },
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    calculate = function(self, card, context)
        if context.press_play and #G.hand.highlighted < 5 then
            local front = pseudorandom_element(G.P_CARDS, pseudoseed('marb_fr'))
            G.playing_card = (G.playing_card and G.playing_card + 1) or 1
            local card = Card(G.play.T.x + G.play.T.w / 2, G.play.T.y, G.CARD_W, G.CARD_H, front, G.P_CENTERS.m_stone,
                { playing_card = G.playing_card })


            table.insert(G.playing_cards, card)
            G.hand:emplace(card)
            card:start_materialize()

            card.base.times_played = card.base.times_played + 1
            card.ability.played_this_ante = true
            G.GAME.round_scores.cards_played.amt = G.GAME.round_scores.cards_played.amt + 1
            draw_card(G.hand, G.play, 1, 'up', nil, card)

            G.E_MANAGER:add_event(Event({
                func = function()
                    SMODS.calculate_context({ playing_card_added = true, cards = card })
                    return true
                end
            }))
            return {
                message = "Crystallize!",
                card = card
            }
        end
    end
}

--Chiori
SMODS.Joker {
    key = 'j_chiori',
    loc_txt = {
        name = "Next customer!",
        text = {
            "If {C:attention}played hand{} contains a",
            "{C:attention}Stone card{}, retrigger all",
            "cards in hand"
        }
    },

    rarity = 2,
    atlas = 'Joker',
    pos = { x = 4, y = 2 },
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { retrigger = -1 } },

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if card.ability.extra.retrigger == -1 then
                for i = 1, #G.play.cards do
                    if G.play.cards[i].ability.effect == 'Stone Card' then
                        card.ability.extra.retrigger = 1
                    end
                end
                if card.ability.extra.retrigger == -1 then
                    card.ability.extra.retrigger = 0
                end
            end

            if card.ability.extra.retrigger == 1 then
                return {
                    message = localize("k_again_ex"),
                    repetitions = 1,
                    card = card,
                }
            end
        end

        if context.after then
            card.ability.extra.retrigger = -1
        end
    end
}

--Aventurine
SMODS.Joker {
    key = 'j_Aventurine',
    loc_txt = {
        name = "The dice have been cast!",
        text = {
            "{C:green}#1# in #2#{} chance to gain",
            "{C:mult}+#4#{} Mult every hand played",
            "{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult)"
        }
    },

    rarity = 1,
    atlas = 'Joker',
    pos = { x = 7, y = 0 },
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { odds = 7, mult = 0, mult_mod = 10 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { '' .. (G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odds, card.ability.extra.mult, card.ability.extra.mult_mod } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if pseudorandom('aventurine') < G.GAME.probabilities.normal / card.ability.extra.odds then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
                card_eval_status_text(card, "extra", nil, nil, nil, { message = localize('k_upgrade_ex') })
            end
        end

        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
                card = card
            }
        end
    end
}

SMODS.Sound({
    key = "TacoBell",
    path = "TacoBell.ogg",
})

--Asta
SMODS.Joker {
    key = 'j_asta',
    loc_txt = {
        name = "Give these trailblazers your blessing!",
        text = {
            "Gains {C:mult}+#3#{} Mult for each",
            "{V:1}#1#{} card in {C:attention}scoring hand{}.",
            "{C:mult}-#4#{} Mult after every hand.",
            "Suit changes every round",
            "{C:inactive}(currently {}{C:mult}+#2#{}{C:inactive} Mult){}"
        }
    },
    rarity = 1,
    atlas = 'Joker',
    pos = { x = 5, y = 2 },
    cost = 5,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { mult = 0, extra_mult = 1, mult_loss = 1 } },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                localize(G.GAME.current_round.asta_suit or "Hearts", "suits_singular"),
                card.ability.extra.mult,
                card.ability.extra.extra_mult,
                card.ability.extra.mult_loss,
                colours = { G.C.SUITS[G.GAME.current_round.asta_suit or "Hearts"] }
            }
        }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local upgraded = false;
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:is_suit(G.GAME.current_round.asta_suit, true) or context.scoring_hand[i].ability.name == "Wild Card" then
                    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.extra_mult;
                    upgraded = true
                end
            end
            if upgraded then
                card_eval_status_text(card, "extra", nil, nil, nil, { message = localize('k_upgrade_ex') })
            end
        end

        if context.joker_main and card.ability.extra.mult > 0 then
            return {
                mult = card.ability.extra.mult,
                mult_message = {
                    message = localize {
                        type = "variable",
                        key = "a_mult",
                        vars = { card.ability.extra.mult }
                    },
                    sound = "GI_TacoBell",
                    colour = G.C.MULT
                }
            }
        end

        if context.after and not context.blueprint and card.ability.extra.mult > 0 then
            card.ability.extra.mult = card.ability.extra.mult - card.ability.extra.mult_loss;
            if card.ability.extra.mult < 0 then
                card.ability.extra.mult = 0
            end
            return {
                message = '-' .. number_format(card.ability.extra.mult_loss),
                colour = G.C.MULT
            }
        end
    end
}

--Mualani
SMODS.Joker {
    key = 'j_Mualani',
    loc_txt = {
        name = "Catch an epic wave!",
        text = {
            "{C:green}#1# in #2#{} chance to crit",
            "for {X:mult,C:white} X#3# {} Mult"
        }
    },

    rarity = 2,
    atlas = 'Joker',
    pos = { x = 2, y = 3 },
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { odds = 2, Xmult = 4 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { '' .. (G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odds, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and pseudorandom('mualani') < G.GAME.probabilities.normal / card.ability.extra.odds then
            return {
                Xmult = card.ability.extra.Xmult,
                card = card
            }
        end
    end
}

--Cerydra
SMODS.Joker {
    key = 'j_cerydra',
    loc_txt = {
        name = "Your downfall is absolute!",
        text = {
            "Retrigger every {C:attention}fourth{}",
            "scored card {C:attention}2{} times",
            "{C:inactive}#1# remaining{}"
        }
    },

    rarity = 1,
    atlas = 'Joker',
    pos = { x = 1, y = 3 },
    cost = 5,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { cards_left = 4, retrigger_req = 4 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cards_left } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            card.ability.extra.cards_left = card.ability.extra.cards_left - 1
            if card.ability.extra.cards_left <= 0 then
                card.ability.extra.cards_left = card.ability.extra.retrigger_req
                return {
                    message = localize("k_again_ex"),
                    repetitions = 2,
                    card = card,
                }
            end
        end
    end
}

--Albedo
SMODS.Joker {
    key = 'j_albedo',
    loc_txt = {
        name = "Moment of birth!",
        text = {
            "After playing a {C:attention}Flush{}{C:inactive}#1#{}, {C:attention}Straight{}{C:inactive}#2#{},",
            "and {C:attention}Four of a kind{}{C:inactive}#3#{} in one round,",
            "creates {C:legendary,E:1}The Soul{} and {C:mult}self destructs{}.",
            "If {C:attention}at least one{} was played, creates",
            "a {C:tarot}Judgement{} at the end of the round",
            "{C:inactive}(Must have room){}"
        }
    },

    rarity = 3,
    atlas = 'Joker',
    pos = { x = 7, y = 2 },
    cost = 10,
    blueprint_compat = false,
    eternal_compat = false,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { first_hand = false, second_hand = false, third_hand = false } },
    loc_vars = function(self, info_queue, card)
        return { vars = { (card.ability.extra.first_hand and "[X]" or "[ ]"), (card.ability.extra.second_hand and "[X]" or "[ ]"), (card.ability.extra.third_hand and "[X]" or "[ ]") } }
    end,

    calculate = function (self, card, context)
        if context.before then
            if context.scoring_name == "Flush" then
                card.ability.extra.first_hand = true
            end
            if context.scoring_name == "Straight" then
                card.ability.extra.second_hand = true
            end
            if context.scoring_name == "Four of a Kind" then
                card.ability.extra.third_hand = true
            end

            if card.ability.extra.first_hand and card.ability.extra.second_hand and card.ability.extra.third_hand and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                SMODS.add_card {
                                    key = "c_soul"
                                }
                                G.GAME.consumeable_buffer = 0
                                card:start_dissolve()
                                return true
                            end
                        }))
                        card_eval_status_text(card, 'extra', nil, nil, nil,
                            { message = "Created!", colour =  G.C.SECONDARY_SET.Spectral })
                        return true
                    end)
                }))
            end
        end

        if context.end_of_round then
            if (card.ability.extra.first_hand or card.ability.extra.second_hand or card.ability.extra.third_hand) and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                SMODS.add_card {
                                    key = "c_judgement"
                                }
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                        card_eval_status_text(card, 'extra', nil, nil, nil,
                            { message = "Created!", colour =  G.C.SECONDARY_SET.Spectral })
                        return true
                    end)
                }))
            end
            card.ability.extra.first_hand = false
            card.ability.extra.second_hand = false
            card.ability.extra.third_hand = false
        end
    end

}

--Sparxie
SMODS.Joker {
    key = 'j_sparxie',
    loc_txt = {
        name = "Party till the end of the word!",
        text = {
            "When {C:chips}hand{}/{C:mult}discard{} has only {C:attention}one card{},",
            "gain {X:mult,C:white} X#1# {} Mult for this round.",
            "{C:green}#4#%{} chance to instead gain {X:mult,C:white} X#2# {} Mult",
            "and restore the used {C:chips}hand{}/{C:mult}discard{}",
            "{C:inactive}(Currently {}{X:mult,C:white} X#3# {}{C:inactive} Mult){}"
        }
    },

    rarity = 3,
    atlas = 'Joker',
    pos = { x = 7, y = 1 },
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { Xmult_mod_low = 0.5, Xmult_mod_high = 1, Xmult = 1, odds = 25 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod_low, card.ability.extra.Xmult_mod_high, card.ability.extra.Xmult, card.ability.extra.odds } }
    end,

    calculate = function (self, card, context)

        if (context.discard or context.before) and #context.full_hand == 1 and not context.blueprint then
            if pseudorandom('sparxie') < card.ability.extra.odds / 100 then
                card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod_high
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    { message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } } , sound = "GI_TacoBell" })
                if G.GAME.current_round.sparxie_activated == false then
                    G.GAME.current_round.sparxie_activated = true
                    if context.discard then
                        ease_discard(1)
                        SMODS.calculate_effect( { message = "+1", colour = G.C.RED }, context.blueprint_card or card)
                    elseif context.before then
                        ease_hands_played(1)
                        SMODS.calculate_effect( { message = "+1", colour = G.C.BLUE }, context.blueprint_card or card)
                    end
                end
            else
                card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod_low
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    { message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } } })
            end
        end

        if context.press_play or context.pre_discard then
            G.GAME.current_round.sparxie_activated = false
        end

        if context.joker_main and card.ability.extra.Xmult > 1 then
            return {
                Xmult = card.ability.extra.Xmult,
                card = card
            }
        end

        if context.end_of_round and not context.blueprint and card.ability.extra.Xmult > 1 then
            card.ability.extra.Xmult = 1
            return {
                message = localize('k_reset'),
                colour = G.C.RED
            }
        end
    end

}

--Phainon
SMODS.Joker {
    key = 'j_phainon',
    loc_txt = {
        name = "Khaslana",
        text = {
            "When in the first joker slot",
            "during a blind, {C:attention}debuffs{} all other",
            "jokers and gives {X:mult,C:white} X#2# {} Mult times",
            "the current {C:attention}Ante{} per other joker",
            "{C:inactive}(Currently {X:mult,C:white} X#1# {} {C:inactive}Mult){}"
        }
    },

    rarity = 4,
    atlas = 'Joker',
    pos = { x = 3, y = 3 },
    cost = 20,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    config = { extra = { Xmult = 1, Xmult_mod = 0.5, activated = false, in_blind = false } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult, card.ability.extra.Xmult_mod } }
    end,
	update = function(self, card, front)
		if G.STAGE == G.STAGES.RUN and G.GAME.blind and G.GAME.blind.chips > 0 and card.ability.extra.in_blind then
            if G.jokers.cards[1] == card then
                if card.ability.extra.activated == false then
                    card.ability.extra.activated = true
                    card.ability.extra.Xmult = (#G.jokers.cards - 1) * card.ability.extra.Xmult_mod * G.GAME.round_resets.ante
                    if card.ability.extra.Xmult < 1 then
                        card.ability.extra.Xmult = 1
                    end
                    card.children.center:set_sprite_pos{ x = 4, y = 3 }
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_disabled_ex'),colour = G.C.FILTER, delay = 0.45})
                    card:set_debuff(false)

                    for i = 2, #G.jokers.cards do
                        G.jokers.cards[i]:set_debuff(true)
                        G.jokers.cards[i]:juice_up()
                    end
                end
			else
                card.ability.extra.activated = false
                card.children.center:set_sprite_pos{ x = 3, y = 3 }
                card.ability.extra.Xmult = 1
            end
            if G.jokers.cards[1] and G.jokers.cards[1].ability.name ~= "j_GI_j_phainon" then
                for i = 1, #G.jokers.cards do
                    G.jokers.cards[i]:set_debuff(false)
				end
            end
		end
	end,

    calculate = function(self, card, context)
        if context.setting_blind then
            if G.jokers.cards[1] == card then
                card.ability.extra.activated = true
                for i = 2, #G.jokers.cards do
                    G.jokers.cards[i]:set_debuff(true)
                    G.jokers.cards[i]:juice_up()
                end
                card.ability.extra.Xmult = (#G.jokers.cards - 1) * card.ability.extra.Xmult_mod * G.GAME.round_resets.ante
                if card.ability.extra.Xmult < 1 then
                    card.ability.extra.Xmult = 1
                end
                card.children.center:set_sprite_pos{ x = 4, y = 3 }
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_disabled_ex'),colour = G.C.FILTER, delay = 0.45})
			end
        end

        if context.ending_shop then
            card.ability.extra.in_blind = true
        end

        if context.end_of_round and context.cardarea == G.jokers then
            for i = 1, #G.jokers.cards do
                G.jokers.cards[i]:set_debuff(false)
            end
            card.ability.extra.in_blind = false
            card.ability.extra.activated = false
            card.children.center:set_sprite_pos{ x = 3, y = 3 }
            card.ability.extra.Xmult = 1
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = "end" ,colour = G.C.FILTER, delay = 0.45})
        end

        if context.joker_main and G.jokers.cards[1] == card then
            return {
                x_mult = card.ability.extra.Xmult
            }
        end
    end
}

--Columbina
SMODS.Joker {
    key = 'j_columbina',
    loc_txt = {
        name = "Columbina Hyposelenia",
        text = {
            "When entering a {C:attention}Small{} or {C:attention}Big Blind{},",
            "upgrades every {C:legendary,E:1}poker hand by {C:attention}1{} level.",
            "When entering a {C:attention}Boss Blind{}, upgrades",
            "most played hand by {C:attention}1{} level"
        }
    },

    rarity = 4,
    atlas = 'Joker',
    pos = { x = 5, y = 3 },
    cost = 20,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    calculate = function(self, card, context)

        if context.setting_blind and not context.blind.boss then
            update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '...', mult = '...', level=''})
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                G.TAROT_INTERRUPT_PULSE = true
                return true end }))
            update_hand_text({delay = 0}, {mult = '+', StatusText = true})
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                return true end }))
            update_hand_text({delay = 0}, {chips = '+', StatusText = true})
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                G.TAROT_INTERRUPT_PULSE = nil
                return true end }))
            update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level='+1'})
            delay(1.3)
            for k, v in pairs(G.GAME.hands) do
                level_up_hand(context.blueprint_card or card, k, true)
            end
            update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
        end

        if context.setting_blind and context.blind.boss then
            local _hand, _tally = nil, 0
            for _, handname in ipairs(G.handlist) do
                if SMODS.is_poker_hand_visible(handname) and G.GAME.hands[handname].played > _tally then
                    _hand = handname
                    _tally = G.GAME.hands[handname].played
                end
            end
            if _hand then
                update_hand_text({ sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 }, {
                    handname = localize(_hand, "poker_hands"),
                    chips = G.GAME.hands[_hand].chips,
                    mult = G.GAME.hands[_hand].mult,
                    level = G.GAME.hands[_hand].level,
                })
		    	level_up_hand(context.blueprint_card or card, _hand, false, 1)
                update_hand_text(
			    { sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
			    { mult = 0, chips = 0, handname = "", level = "" }
		        )
            end
        end
    end
}

--Aha
SMODS.Joker {
    key = "j_aha",
    loc_txt = {
        name = "Aha",
        text = {
            "When {C:attention}blind{} is selected, {C:attention}destroy{}",
            "a random {C:attention}non-negative{} Joker and",
            "create a random {C:dark_edition}Negative{} {C:green}Uncommon{}",
            "{C:red}Rare{} or {C:legendary,E:1}Legendary{} Joker"
        }
    },

    rarity = 4,
    atlas = 'Joker',
    pos = { x = 6, y = 3 },
    cost = 20,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    allow_duplicates = false,

    calculate = function(self, card, context)
        if context.setting_blind then
            local destructable_jokers = {}
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card and not SMODS.is_eternal(G.jokers.cards[i], card) and not G.jokers.cards[i].getting_sliced and not (G.jokers.cards[i].edition and G.jokers.cards[i].edition.negative) then
                    destructable_jokers[#destructable_jokers + 1] =
                        G.jokers.cards[i]
                end
            end
            local joker_to_destroy = pseudorandom_element(destructable_jokers, 'j_aha')

            if joker_to_destroy then
                joker_to_destroy.getting_sliced = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        (context.blueprint_card or card):juice_up(0.8, 0.8)
                        joker_to_destroy:start_dissolve({ G.C.RED }, nil, 1.6)
                        return true
                    end
                }))
            end

            G.E_MANAGER:add_event(Event({
                func = function()
                    local random_value = pseudorandom("j_aha")
                    if (random_value >= 0.98) then
                        SMODS.add_card {
                            set = 'Joker',
                            rarity = 'Legendary',
                            edition = 'e_negative',
                            key_append = 'aha'
                        }
                    elseif (random_value >= 0.5) then
                        SMODS.add_card {
                            set = 'Joker',
                            rarity = 'Rare',
                            edition = 'e_negative',
                            key_append = 'aha'
                        }
                    else
                        SMODS.add_card {
                            set = 'Joker',
                            rarity = 'Uncommon',
                            edition = 'e_negative',
                            key_append = 'aha'
                        }
                    end
                    return true
                end
            }))
            return {
                message = "Elated!",
                colour = G.C.MULT,
                card = context.blueprint_card or card
            }
        end
    end,
}

--Evernight
--Creates an Evey every round
--Evey/consumable
--Sell/use this card to give single-use scoring? idk how it'd work just yet


--? (someone like ororon of fischl who activates on elemental reactions, Ifa Ororon could be fun)
--gains stats for every time a card changes suit

--Mavuika
--Gives more chips/mult depending on how many different poker hands / highets poker hand played this run
--New CDCDC2F poker hand unlocked??????

