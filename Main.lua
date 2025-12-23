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
            ease_dollars(to_big(card.ability.extra.cost))
            card:juice_up(0.3, 0.4)
        end

        if context.money_changed and not context.blueprint then
            card.ability.extra.current_count = card.ability.extra.current_count + math.sqrt(context.money_changed ^ 2)

            while to_big(card.ability.extra.current_count) >= to_big(card.ability.extra.req_change) do
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
            card:juice_up(0.3, 0.4)
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
            -- money_amount = to_big(context.money_changed)
            -- if to_big(money_amount) < to_big(0) then
            if context.money_changed < 0 then
                ease_dollars(card.ability.extra.money)
                return {
                    message = "$1",
                    colour = G.C.MONEY,
                    card = card
                }
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

    config = { extra = { chips_mod = 20, chips = 0 } },
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
                    if suits["Diamond"] == 0 then
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
        if context.joker_main and (to_big(card.ability.extra.chips) > to_big(0)) then
            return {
                chips = card.ability.extra.chips,
                card = card
            }
        end
    end
}

--Kazuha
SMODS.Joker {
    key = 'j_kazuha',
    loc_txt = {
        name = "One with wind and clouds!",
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
        name = "(@.@)",
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

--Escoffier
SMODS.Joker {
    key = 'j_escoffier',
    loc_txt = {
        name = "Goose on the loose!",
        text = {
            "If {C:attention}poker hand{} contains 1/2/3/4/5",
            "{C:diamonds}Diamond{} or {C:clubs}Club{} cards, this joker",
            "gains {C:mult}+#1#{}/{C:mult}+#1#{}/{C:mult}+#2#{}/{C:mult}+#2#{}/{C:mult}+#3#{} Mult",
            "{C:inactive}[currently {C:mult}+#4#{} {C:inactive}Mult]"
        }
    },

    rarity = 2,
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

            if cardcount == 1 or cardcount == 2 then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.extra_mult_1
            elseif cardcount == 3 or cardcount == 4 then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.extra_mult_2
            elseif cardcount == 5 then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.extra_mult_3
            end

            if cardcount > 0 then
                card_eval_status_text(card, "extra", nil, nil, nil, { message = localize('k_upgrade_ex') })
            end
        end

        if context.joker_main and (to_big(card.ability.extra.mult) > to_big(0)) then
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

        if context.joker_mains then
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

--Durin
SMODS.Joker {
    key = 'j_durin',
    loc_txt = {
        name = "It's Durin' time!",
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

    config = { extra = { money = 4, Xmult = 3 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.before and not next(context.poker_hands["Flush"]) and not next(context.poker_hands["Straight"]) and not next(context.poker_hands["Full House"]) and not next(context.poker_hands["Four of a Kind"]) then
            ease_dollars(to_big(card.ability.extra.money))
            return {
                message = "$4",
                colour = G.C.MONEY,
                card = card
            }
        end

        if context.joker_main and (next(context.poker_hands["Flush"]) or next(context.poker_hands["Straight"]) or next(context.poker_hands["Full House"]) or next(context.poker_hands["Four of a Kind"])) then
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
        if context.after and G.GAME.current_round.hands_left == 0 and to_big(G.GAME.dollars) >= to_big(card.ability.extra.cost) and to_big(G.GAME.chips) + to_big(hand_chips * mult) < to_big(G.GAME.blind.chips) then
            ease_hands_played(card.ability.extra.extra_hands)
            ease_dollars(to_big(card.ability.extra.cost) * to_big(-1))
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

    config = { extra = { display_text = "Still charging ult...", display_text2 = "(surely she gets it soon)", Xmult = 1.2, low_Xmult = 1.2, fake_Xmult = 10 } },
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
            "Gains {X:mult,C:white} X#1# {} Mult every ",
            "time a {C:attention}Stone card{} is scored.",
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

    config = { extra = { Xmult_mod = 0.25, Xmult = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card.ability.effect == 'Stone Card' and not context.blueprint then
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
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:is_suit(G.GAME.current_round.asta_suit, true) or context.scoring_hand[i].ability.name == "Wild Card" then
                    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.extra_mult;
                end
            end
            card_eval_status_text(card, "extra", nil, nil, nil, { message = localize('k_upgrade_ex') })
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
        if context.joker_main and pseudorandom('bloodstone') < G.GAME.probabilities.normal / card.ability.extra.odds then
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

--Phainon
SMODS.Joker {
    key = 'j_phainon',
    loc_txt = {
        name = "Khaslana",
        text = {
            "When in the first joker slot",
            "during a blind, {C:attention}debuffs{} all other",
            "jokers and gives {X:mult,C:white} X#2# {} Mult",
            "per joker debuffed in this way.",
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

    config = { extra = { Xmult = 1, Xmult_mod = 3, activated = false, in_blind = false } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult, card.ability.extra.Xmult_mod } }
    end,
	update = function(self, card, front)
		if G.STAGE == G.STAGES.RUN and card.ability.extra.in_blind == true then
            if G.jokers.cards[1] == card then
                if card.ability.extra.activated == false then
                    card.ability.extra.activated = true
                    card.ability.extra.Xmult = (#G.jokers.cards - 1) * card.ability.extra.Xmult_mod + 1
                    card.children.center:set_sprite_pos{ x = 4, y = 3 }
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_disabled_ex'),colour = G.C.FILTER, delay = 0.45})
                    for i = 2, #G.jokers.cards do
                        G.jokers.cards[i]:set_debuff(true)
                        G.jokers.cards[i]:juice_up()
                    end
                end
			else
                card.ability.extra.activated = false
                for i = 1, #G.jokers.cards do
                    G.jokers.cards[i]:set_debuff(false)
				end
                card.children.center:set_sprite_pos{ x = 3, y = 3 }
                card.ability.extra.Xmult = 1
            end
		end
	end,

    calculate = function(self, card, context)
        if context.setting_blind then
            card.ability.extra.in_blind = true
            if G.jokers.cards[1] == card then
                card.ability.extra.activated = true
                for i = 2, #G.jokers.cards do
                    G.jokers.cards[i]:set_debuff(true)
                    G.jokers.cards[i]:juice_up()
                end
                card.ability.extra.Xmult = (#G.jokers.cards - 1) * card.ability.extra.Xmult_mod + 1
                card.children.center:set_sprite_pos{ x = 4, y = 3 }
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_disabled_ex'),colour = G.C.FILTER, delay = 0.45})
			end
        end



        if context.end_of_round and context.cardarea == G.jokers then
            card.ability.extra.in_blind = false
            for i = 1, #G.jokers.cards do
                G.jokers.cards[i]:set_debuff(false)
            end
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


--Evernight
--Creates an Evey every round
--Evey/consumable
--Sell/use this card to give single-use scoring? idk how it'd work just yet

--anemo
--on first hand, convert all cards to the same suit as the first card

--? (someone like ororon of fischl who activates on elemental reactions, Ifa Ororon could be fun)
--gains stats for every time a card changes suit

--Mavuika
--Gives more chips/mult depending on how many different poker hands / highets poker hand played this run
--New CDCDC2F poker hand unlocked??????

--Character with frontloaded damage
--Mult on first hand of round? idk maybe a little uninteresting
