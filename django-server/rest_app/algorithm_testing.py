import random
from datetime import timedelta, datetime
from random import randrange, sample
from timeit import default_timer as timer

import matplotlib.pyplot as plt
import networkx as nx


def timeit(method):
    def timed(*args, **kw):
        ts = timer()
        result = method(*args, **kw)
        te = timer()
        if 'log_time' in kw:
            name = kw.get('log_name', method.__name__.upper())
            kw['log_time'][name] = int((te - ts) * 1000)
        else:
            print('%r  %2.2f ms' % \
                  (method.__name__, (te - ts) * 1000))
        return result
    return timed


class User:
    corona_spread_rate = 1 / 2

    def __init__(self, pk):
        self.pk = pk
        self.has_corona = False
        self._risk = 0.0

    @property
    def risk(self):
        return self._risk

    @risk.setter
    def risk(self, value):
        if value >= 1:
            self._risk = 1
        else:
            self._risk = value

    @staticmethod
    def gen_users(num):
        users = []

        for i in range(num):
            user = User(i)
            is_infected = random.randint(0, 4)
            if is_infected == 1:
                user.has_corona = True
                user.risk = 1
            users.append(user)

        return users

all_users = User.gen_users(20)

class Interaction:
    def __init__(self, pk):
        self.pk = pk
        self.users = []
        self.date = self._random_date()
        self._total_risk = 0

    def _random_date(self):
        """
        This function will return a random datetime between two datetime
        objects.
        """
        end = datetime.now()
        start = end - timedelta(weeks=3)

        delta = end - start
        int_delta = (delta.days * 24 * 60 * 60) + delta.seconds
        random_second = randrange(int_delta)
        return start + timedelta(seconds=random_second)

    @property
    def total_risk(self):
        return self._total_risk

    @total_risk.setter
    def total_risk(self, value):
        if value >= 1:
            self._total_risk = 1
        else:
            self._total_risk = value

    @property
    def is_expired(self):
        two_week_threshold = datetime.now() - timedelta(weeks=2)
        expired = self.date < two_week_threshold
        if expired:
            print(f"Date {str(self.date)}  outside of threshold of weeks")
        return expired

    def spread_corona_to_users(self):
        avg_corona = 0
        for user in self.users:
            user = all_users[user]
            avg_corona += user.risk * User.corona_spread_rate
        avg_corona = avg_corona / len(self.users)
        self.total_risk = avg_corona

        for user in self.users:
            user = all_users[user]
            user.risk = user.risk + self.total_risk

    def _create_interaction(self):
        num_users = random.randint(2, 5)
        users = sample(all_users, num_users)
        for user in users:
            self.users.append(user.pk)

    @staticmethod
    def gen_ex_interactions(num_interactions):
        inters = []

        for i in range(num_interactions):
            interact = Interaction(i)
            interact._create_interaction()
            inters.append(interact)
        return inters


interactions = Interaction.gen_ex_interactions(10)



# nx.draw(F)
# plt.show()
#G = interactions[0].gen_graph()

class CenterNode:
    def __str__(self):
        return ""

def gen_all_nodes():
    g = nx.Graph()
    for user in all_users:
        g.add_node(user.pk)
    return g

def gen_node_color_map(nodes):
    colors = []
    for node in nodes:
        if isinstance(node, CenterNode):
            colors.append('black')
        else:
            if all_users[node].has_corona:
                colors.append('tab:red')
            else:
                colors.append('tab:blue')
    return colors

def gen_connections_to_events(graph):
    events_used = 0
    for event in interactions:
        center_node = CenterNode()
        if not event.is_expired:
            events_used += 1
            for pk in range(len(event.users)):
                if all_users[pk].has_corona:
                    graph.add_node(pk, corona=True)
                else:
                    graph.add_node(pk, corona=False)
                graph.add_edge(center_node, event.users[pk])
    print(f"{events_used} events actually used. {len(interactions) - events_used} expired")

def get_connections_to_node(node, graph: nx.Graph):
    direct_corona_conns = 0
    events = get_events_for_node(node, graph)
    for event in events:
        neighbors = graph.neighbors(event)
        for n in neighbors:
            if not isinstance(n, CenterNode) and n != node:
                user = all_users[n]
                if user.has_corona:
                    direct_corona_conns += 1

    print(f"{direct_corona_conns} direct connections!!")

def get_corona_users():
    cases = []
    for user in all_users:
        if user.has_corona:
            cases.append(user.pk)
    return cases

def get_corona_risks():
    for user in all_users:
        print(f"User {user.pk}: {user.risk}")

def get_events_for_node(node, graph):
    events = []
    direct_neighbors = graph.neighbors(node)
    for node in direct_neighbors:
        if isinstance(node, CenterNode):
            events.append(node)
    return events


def spread_corona():
    for event in interactions:
        if not event.is_expired:
            event.spread_corona_to_users()


@timeit
def make_graph2():
    # include non-connected
    # G = gen_all_nodes()
    G = nx.Graph()
    gen_connections_to_events(G)
    color_map = gen_node_color_map(G)
    return G, color_map



G, color_map = make_graph2()
nx.draw(G, node_color=color_map, with_labels=True)
plt.show()
get_connections_to_node(1, G)


