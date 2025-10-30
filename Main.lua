SMODS.Atlas{
    key = 'Joker',
    path = 'jokers.png',
    px = 71,
    py = 95
}

SMODS.Atlas{
    key = 'placeholder',
    path = 'glorp.png',
    px = 71,
    py = 95
}

local ease_dollars_ref = ease_dollars
function ease_dollars(mod)
     ease_dollars_ref(mod)
     SMODS.calculate_context{money_changed = mod}
end

--Furina
SMODS.Joker{
    key = 'j_furina',
    loc_txt = {
        name = "Shower me with praise!",
        text = {
            "{C:red}-$#5#{} every hand played",
            "Gains {X:mult,C:white} X#4# {} Mult for every",
            "{C:money}$#1#{} {C:inactive}[#2#]{} gained or lost",
            "{C:inactive}(Currently {X:mult,C:white} X#3# {}){}"
        }
    },
    
    rarity = 3,
    atlas = 'Joker',
    pos = {x = 4, y = 0},
    cost = 9,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,  
    allow_duplicates = false,
    
    config = { extra = {req_change = 13, current_count = 0, Xmult = 1, Xmult_inc = 0.1, cost = -2} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.req_change, card.ability.extra.current_count, card.ability.extra.Xmult, card.ability.extra.Xmult_inc, card.ability.extra.cost*-1} }
    end,
    
    calculate = function(self, card, context)
        if context.before then  
            ease_dollars(lenient_bignum(card.ability.extra.cost))
            card:juice_up(0.3, 0.4)
        end

        if context.money_changed and not context.blueprint then
            card.ability.extra.current_count = card.ability.extra.current_count + math.sqrt(context.money_changed ^2)
            
            while to_big(card.ability.extra.current_count) >= to_big(card.ability.extra.req_change) do
                
                card.ability.extra.current_count = card.ability.extra.current_count - card.ability.extra.req_change

                card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_inc
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra.Xmult}}})
            end

        end

        if context.joker_main then
            return{
                Xmult = card.ability.extra.Xmult,
                card = card
            }
        end
    end
}

--Neuvi
SMODS.Joker{
    key = 'j_neuvillette',
    loc_txt = {
        name = "Settle down!",
        text = {
            "{C:red}-$#2#{} when leaving",
            "the shop. {C:money}+$#1#{} at",
            "the end of the round",
        }
    },
    
    rarity = 1,
    atlas = 'Joker',
    pos = {x = 6, y = 0},
    cost = 6,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,  
    allow_duplicates = false,
    
    config = { extra = {gain = 20, loss = 14} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.gain, card.ability.extra.loss} }
    end,
    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            ease_dollars(lenient_bignum(card.ability.extra.loss*-1))
            card:juice_up(0.3, 0.4)
        end
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.gain
    end
}

--Hyacine
SMODS.Joker{
    key = 'j_hyacine',
    loc_txt = {
        name = "Have some sunshine!",
        text = {
            "{C:money}+$#1#{} anytime",
            "money is lost."
        }
    },
    
    rarity = 2,
    atlas = 'Joker',
    pos = {x = 2, y = 1},
    cost = 7,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,  
    allow_duplicates = false,
    
    config = { extra = {money = 1} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.money} }
    end,
    
    calculate = function(self, card, context)
        if context.money_changed then
            -- money_amount = to_big(context.money_changed)
            -- if to_big(money_amount) < to_big(0) then
            if to_big(context.money_changed) < to_big(0) then
                ease_dollars(lenient_bignum(card.ability.extra.money))
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
	if not G.GAME.current_round.ajaw_card then
		G.GAME.current_round.ajaw_card = {}
	end
	G.GAME.current_round.ajaw_card.suit = "Spades"
	local valid_castle_cards = {}
	for k, v in ipairs(G.playing_cards) do
		if not SMODS.has_no_suit(v) then
			valid_castle_cards[#valid_castle_cards + 1] = v
		end
	end
	if valid_castle_cards[1] then
		local castle_card = pseudorandom_element(valid_castle_cards)
		if not G.GAME.current_round.ajaw_card then
			G.GAME.current_round.ajaw_card = {}
		end
		G.GAME.current_round.ajaw_card.suit = castle_card.base.suit
	end
end

--Ajaw
SMODS.Joker{
    key = 'j_ajaw',
    loc_txt = {
        name = "Almighty Ku'hul Ajaw",
        text = {
            "After discarding {C:attention}#2#{} {C:inactive}[#3#]",
            "{C:attention}#1#{} cards, {X:mult,C:white} X#4# {} Mult", 
            "for the next hand. Suit",
            "and count reset each round"
        }
    },
    rarity = 2,
    atlas = 'Joker',
    pos = {x = 3, y = 0},
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,  
    allow_duplicates = false,
    
    config = { extra = {Ajaw_suit = "Hearts", Xmult = 3, discard_req = 4, current_stacks = 0} },
    loc_vars = function(self, info_queue, card)
        return { vars = {
            localize(
					G.GAME.current_round.ajaw_card and G.GAME.current_round.ajaw_card.suit or "Spades",
					"suits_singular"
				), 
            card.ability.extra.discard_req, 
            card.ability.extra.current_stacks, 
            card.ability.extra.Xmult} }
    end,

    calculate = function(self, card, context)
        if context.discard and context.other_card:is_suit(G.GAME.current_round.ajaw_card.suit) and not context.blueprint then
            local eval = function() return card.ability.extra.current_stacks >= card.ability.extra.discard_req end
                juice_card_until(card, eval, true)
            card.ability.extra.current_stacks = card.ability.extra.current_stacks + 1
            if card.ability.extra.current_stacks == card.ability.extra.discard_req then
                return{
                    message = "Activated",
                    colour = G.C.FILTER,
                    card = card
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.current_stacks >= card.ability.extra.discard_req then
                return{
                    Xmult = card.ability.extra.Xmult,
                    card = card
                }
            end
        end

        if context.after and card.ability.extra.current_stacks >= card.ability.extra.discard_req then 
            card.ability.extra.current_stacks = 0
        end

        if context.end_of_round then
            card.ability.extra.current_stacks = 0
        end
    end
}

--Nilou
SMODS.Joker{
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
    pos = {x = 5, y = 0},
    cost = 5,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,  
    allow_duplicates = false,

    config = { extra = {chips_mod = 20, chips = 0} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.chips_mod, card.ability.extra.chips} }
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
                card.ability.extra.chips = lenient_bignum(to_big(card.ability.extra.chips) + card.ability.extra.chips_mod)
					
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
SMODS.Joker{
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
    rarity = 2,
    atlas = 'Joker',
    pos = {x = 0, y = 0},
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,  
    allow_duplicates = false,
    
    config = { extra = {Xmult = 1.5, suit = "none"} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.Xmult, card.ability.extra.suit} }
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
            if context.scoring_hand[1].ability.name == 'Wild Card' then card.ability.extra.suit = 'all'
            elseif context.scoring_hand[1]:is_suit('Spades', true) then card.ability.extra.suit = 'Spades'
            elseif context.scoring_hand[1]:is_suit('Hearts', true) then card.ability.extra.suit = 'Hearts'
            elseif context.scoring_hand[1]:is_suit('Clubs', true) then card.ability.extra.suit = 'Clubs'
            elseif context.scoring_hand[1]:is_suit('Diamonds', true) then card.ability.extra.suit = 'Diamonds' end

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
SMODS.Joker{
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
    pos = {x = 1, y = 0},
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,  
    allow_duplicates = false,
    
    config = { extra = {Xmult = 2, hand_req = 4, hands_left = 4, hands_bonus = 1} },
    loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.extra.Xmult,
            card.ability.extra.hand_req, 
            card.ability.extra.hands_left, 
            card.ability.extra.hands_bonus} }
    end,

    calculate = function(self, card, context)
        if context.after then
            local reset = false
            if card.ability.extra.hands_left == 0 then
                card.ability.extra.hands_left = card.ability.extra.hand_req
                reset = true
            end
            
            if not context.blueprint and not reset then
                card.ability.extra.hands_left = card.ability.extra.hands_left -1
            end 

            if card.ability.extra.hands_left == 0 then
                ease_hands_played(card.ability.extra.hands_bonus)
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_hands', vars = {card.ability.extra.hands_bonus}}})
                local eval = function() return card.ability.extra.hands_left == 0 end
                    juice_card_until(card, eval, true)
            end
        end

        if context.joker_main then
            if card.ability.extra.hands_left == 0 then
                return{
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
		-- insert base game food jokers
		self:inject_card(G.P_CENTERS.c_world)
		self:inject_card(G.P_CENTERS.c_sun)
		self:inject_card(G.P_CENTERS.c_moon)
		self:inject_card(G.P_CENTERS.c_star)
		self:inject_card(G.P_CENTERS.c_lovers)
	end,
})
--Venti
SMODS.Joker{
    key = 'j_venti',
    loc_txt = {
        name = "Time for takeoff!",
        text = {
            "Randomly creates a {C:attention}Suit changing{}",
            "{C:attention}Tarot{} or {C:attention}The lovers{} if played hand",
            "contains at least {C:attention}4 scoring{} cards.",
            "Max twice per round",
            "{C:inactive}(Must have room){}"
        }
    },
    
    rarity = 2,
    atlas = 'Joker',
    pos = {x = 1, y = 1},
    cost = 7,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,  
    allow_duplicates = false,

    config = { extra = {limit = 2, made = 0, blueprint_buffer = false} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.limit, card.ability.extra.made, card.ability.extra.blueprint_buffer} }
    end,

    calculate = function(self, card, context)
		if context.before and #context.scoring_hand >= 4 
        and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit 
        and (card.ability.extra.made < card.ability.extra.limit
        or (card.ability.extra.blueprint_buffer and context.blueprint)) then
			G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
            func = (function()
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        local card = create_card('Suiter',G.consumeables, nil, nil, nil, nil, nil, 'kaveh')
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                        G.GAME.consumeable_buffer = 0
                        return true
                    end}))   
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.PURPLE})                       
                return true
            end)}))

            if not context.blueprint then
                card.ability.extra.made = card.ability.extra.made + 1
                card.ability.extra.blueprint_buffer = true
            end
        end
        if context.after then 
            card.ability.extra.blueprint_buffer = false
        end

        if context.end_of_round then
            card.ability.extra.made = 0
            
        end
	end
}

--Escoffier
SMODS.Joker{
    key = 'j_escoffier',
    loc_txt = {
        name = "Goose on the loose!",
        text = {
            "If {C:attention}poker hand{} contains 1/2/3/4/5",
            "{C:hearts}Heart{} or {C:spades}Spade{} cards and does",
            "not contain a {C:attention}Flush{}, this joker",
            "gains {C:mult}+#1#{}/{C:mult}+#1#{}/{C:mult}+#2#{}/{C:mult}+#2#{}/{C:mult}+#3#{} Mult.",
            "{C:inactive}[currently {C:mult}+#4#{} {C:inactive}Mult]"
        }
    },
    
    rarity = 1,
    atlas = 'Joker',
    pos = {x = 0, y = 1},
    cost = 5,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,  
    allow_duplicates = false,

    config = { extra = {extra_mult_1 = 1, extra_mult_2 = 2, extra_mult_3 = 3, mult = 0} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.extra_mult_1, card.ability.extra.extra_mult_2, card.ability.extra.extra_mult_3, card.ability.extra.mult} }
    end,

    calculate = function(self, card, context)
		if context.before and not context.blueprint and not next(context.poker_hands["Flush"]) then
            local cardcount = 0
			for i = 1, #context.scoring_hand do
                if context.scoring_hand[i].ability.name == 'Wild Card' or context.scoring_hand[i]:is_suit('Spades', true) or context.scoring_hand[i]:is_suit('Hearts', true) then 
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

            if cardcount >0 then
                card_eval_status_text(card, "extra", nil, nil, nil, {
                    message = localize({
                        type = "variable",
                        key = "a_mult",
                        vars = { number_format(card.ability.extra.mult) },
                    }),
                    colour = G.C.MULT,
                })	
            end
		end

		if context.joker_main and (to_big(card.ability.extra.mult) > to_big(0)) then
			return {
                mult = card.ability.extra.mult
			}
		end
	end
}

--Herta
SMODS.Joker{
    key = 'j_herta',
    loc_txt = {
        name = "Nothing but a void!",
        text = {
            "For every {C:attention}scoring card{} played, ",
            "this joker gains {X:mult,C:white} X#1# {} Mult for",
            "the {C:attention}final hand{} of the round",
            "{C:inactive}[currently {X:mult,C:white} X#2# {} Mult]{}"
        }
    },
    
    rarity = 2,
    atlas = 'Joker',
    pos = {x = 4, y = 1},
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,  
    allow_duplicates = false,

    config = { extra = {Xmult_mod = 0.2, Xmult = 1} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.Xmult_mod, card.ability.extra.Xmult} }
    end,

    calculate = function(self, card, context)
		if context.before and not context.blueprint then
			for i = 1, #context.scoring_hand do
                card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
            end
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra.Xmult}}})
            		
		end

		if context.joker_main and G.GAME.current_round.hands_left == 0 then
			return{
                Xmult = card.ability.extra.Xmult,
                card = card
            }
		end

        if context.end_of_round then
            card.ability.extra.Xmult = 1
        end
	end
}

--Durin
SMODS.Joker{
    key = 'j_durin',
    loc_txt = {
        name = "It's Durin' time!",
        text = {
            "{C:money}+$#1#{} if poker hand is a",
            "{C:attention}Three of a kind{} or lower.",
            "{X:mult,C:white} X#2# {} Mult If poker hand is a",
            "{C:attention}Straight{} or higher"
        }
    },
    
    rarity = 3,
    atlas = 'Joker',
    pos = {x = 3, y = 1},
    cost = 7,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,  
    allow_duplicates = false,
    
    config = { extra = {money = 4, Xmult = 3} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.money, card.ability.extra.Xmult} }
    end,
    
    calculate = function(self, card, context)
        if context.before and not next(context.poker_hands["Flush"]) and not next(context.poker_hands["Straight"]) and not next(context.poker_hands["Full House"]) and not next(context.poker_hands["Four of a Kind"])then  
            ease_dollars(lenient_bignum(card.ability.extra.money))
            return {
                message = "$4",
                colour = G.C.MONEY,
                card = card
            }
        end

        if context.joker_main and (next(context.poker_hands["Flush"]) or next(context.poker_hands["Straight"]) or next(context.poker_hands["Full House"]) or next(context.poker_hands["Four of a Kind"]))then
            return{
                Xmult = card.ability.extra.Xmult,
                card = card
            }
        end
    end
}

--Castorice
SMODS.Joker{
    key = 'j_cassie',
    loc_txt = {
        name = "Return to dust!",
        text = {
            "If you run out hands, gain",
            "{C:chips}+#1#{} Hand and {C:mult}lose $#3#{}.",
            "Money lost gets doubled for",
            "every trigger this round."
        }
    },
    
    rarity = 2,
    atlas = 'placeholder',
    pos = {x = 0, y = 0},
    cost = 7,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,  
    allow_duplicates = false,

    config = { extra = {extra_hands = 1, base_cost = 5, cost = 5} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.extra_hands, card.ability.extra.base_cost, card.ability.extra.cost} }
    end,

    calculate = function(self, card, context)
		if context.after and G.GAME.current_round.hands_left == 0 and to_big(G.GAME.dollars) >= to_big(card.ability.extra.cost) and to_big(G.GAME.chips) + to_big(hand_chips * mult) < to_big(G.GAME.blind.chips) then
            ease_hands_played(card.ability.extra.extra_hands)
            ease_dollars(to_big(card.ability.extra.cost) * to_big(-1))
            card.ability.extra.cost = card.ability.extra.cost * 2
			return{
                message = '-$',
                colour = G.C.MULT
            }
		end

        if context.end_of_round then
            card.ability.extra.cost = card.ability.extra.base_cost
        end
	end
}

--Cyrene
--Gives a ton of mult but only outside of the actual round