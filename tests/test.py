from dataclasses import dataclass, field
from functools import reduce
from typing import override
import random
import math
import devtools as dev


BODY_COUNT = 4
MIN_DISTANCE = 0.0001


@dataclass
class Vector3:
    x: float
    y: float
    z: float

    @property
    def length_squared(self) -> float:
        return pow(self.x, 2) + pow(self.y, 2) + pow(self.z, 2)

    @property
    def length(self) -> float:
        return math.sqrt(self.length_squared)

    def __mul__(self, other: Vector3 | float) -> Vector3:
        if isinstance(other, Vector3):
            return Vector3(
                self.x * other.x,
                self.y * other.y,
                self.z * other.z,
            )
        return Vector3(self.x * other, self.y * other, self.z * other)

    def __add__(self, other: Vector3 | float) -> Vector3:
        if isinstance(other, Vector3):
            return Vector3(
                self.x + other.x,
                self.y + other.y,
                self.z + other.z,
            )
        return Vector3(self.x + other, self.y + other, self.z + other)

    def __sub__(self, other: Vector3 | float) -> Vector3:
        if isinstance(other, Vector3):
            return Vector3(
                self.x - other.x,
                self.y - other.y,
                self.z - other.z,
            )
        return Vector3(self.x - other, self.y - other, self.z - other)

    def __lt__(self, other: Vector3) -> bool:
        return self.length_squared < other.length_squared

    def __le__(self, other: Vector3) -> bool:
        return self.length_squared <= other.length_squared

    @override
    def __eq__(self, other: object) -> bool:
        if isinstance(other, Vector3):
            return self.length_squared == other.length_squared
        return False

    @override
    def __ne__(self, other: object) -> bool:
        return not self.__eq__(other)

    def __gt__(self, other: Vector3) -> bool:
        return self.length_squared > other.length_squared

    def __ge__(self, other: Vector3) -> bool:
        return self.length_squared >= other.length_squared

    @override
    def __hash__(self) -> int:
        return hash(self.length_squared)


@dataclass
class Body:
    position: Vector3
    velocity: Vector3
    radius: float
    mass: float

    _acceleration: Vector3 = field(default=Vector3(0, 0, 0), init=False)

    @property
    def acceleration(self) -> Vector3:
        return self._acceleration

    @acceleration.setter
    def acceleration(self, value: Vector3) -> None:
        self._acceleration = value


def step(bodies: list[Body]) -> list[Body]:
    for i in range(len(bodies)):
        p1 = bodies[i].position

        for j in range(i + 1, len(bodies)):
            p2 = bodies[j].position
            m2 = bodies[j].mass
            r = p2 - p1
            mag_sq = r.x * r.x + r.y * r.y
            mag = math.sqrt(mag_sq)

            a1 = r * (m2 / (mag_sq * mag))
            bodies[i].acceleration += a1

    return bodies


def main() -> None:
    bodies: list[Body] = []

    for _ in range(BODY_COUNT):
        a = random.random() * math.tau
        cos = math.cos(a)
        sin = math.sin(a)

        r_values = [random.random() for _ in range(6)]
        r0 = reduce(lambda x, y: x + y, r_values)
        r1 = abs(r0 / 3.0 - 1.0)
        position = Vector3(cos, 0, sin) * math.sqrt(BODY_COUNT) * 10.0 * r1
        velocity = Vector3(sin, 0, -cos)

        bodies.append(Body(position, velocity, r1, 1.0))

    bodies.sort(key=lambda x: x.position)

    for i, body in enumerate(bodies):
        v = math.sqrt(i / body.position.length)
        body.velocity *= v

    bodies = step(bodies)

    for body in bodies:
        dev.debug(vars(body))


if __name__ == "__main__":
    main()
